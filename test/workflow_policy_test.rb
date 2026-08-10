# frozen_string_literal: true

require "English"
require "fileutils"
require "minitest/autorun"
require "open3"
require "tmpdir"
require "yaml"

class ManualWorkflowPolicy
  WORKFLOW = File.expand_path("../.github/workflows/manual-cask-validation.yml", __dir__)
  WORKFLOW_DIR = File.expand_path("../.github/workflows", __dir__)
  WORKFLOW_FILENAME = "manual-cask-validation.yml"
  EXPECTED_RUNNER = %w[self-hosted macOS ARM64 homebrew-mighty-manual].freeze
  CHECKOUT_SHA = "actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683"
  EXPECTED_JOB_CONDITION = [
    "github.event_name == 'workflow_dispatch'",
    "github.ref == 'refs/heads/main'",
    "github.ref_protected == true",
    "github.repository == 'mikezamayias/homebrew-mighty'",
    "github.sha != ''",
  ].join("&&").gsub(/\s+/, "").freeze
  FORBIDDEN_TRIGGERS = %w[
    pull_request pull_request_target push schedule repository_dispatch workflow_call
  ].freeze
  READ_ONLY_PERMISSION_VALUES = %w[none read].freeze
  SECRET_KEY_PATTERN = /secret/i
  SECRET_CONTEXT_PATTERN = /\bsecrets?\b/i
  SAFE_GIT_COMMANDS = [
    /\bgit\s+rev-parse\s+HEAD(?=$|[\r\n\)\]\}"'`;|&])/,
    /\bgit\s+branch\s+--show-current(?=$|[\r\n\)\]\}"'`;|&])/,
    /\bgit\s+ls-files\s+--error-unmatch\s+--(?=\s|$)/,
  ].freeze
  FORBIDDEN_COMMANDS = [
    /\bbrew\s+(?:bump|cleanup|create|edit|install|link|reinstall|tap|tap-new|uninstall|unlink|untap|update|upgrade)\b/i,
    /\b(?:gem|bundle)\s+install\b/i,
    /\bgh\s+(?:pr\s+create|release|workflow\s+run)\b/i,
    /\bgh\s+api\b[^\n]*(?:(?:--method(?:=|\s+)|-X(?:=|\s*)))(?:POST|PUT|PATCH|DELETE)\b/i,
    /\b(?:gem\s+push|npm\s+publish|yarn\s+publish|pnpm\s+publish)\b/i,
    /\b(?:curl|wget)\b[^\n]*(?:--request|-X)\s*(?:DELETE|PATCH|POST|PUT)\b/i,
    /\b(?:sed\s+-i|perl\s+-pi|ruby\s+-pi)\b/i,
    /(?:>|>>)\s*Casks\//,
    /\b(?:bump-cask-pr|cask-update|update-cask)\b/i,
  ].freeze

  attr_reader :errors

  def initialize(path = WORKFLOW, document: nil)
    @document = document || YAML.safe_load_file(path, aliases: false)
    @errors = []
  end

  def validate
    validate_triggers
    validate_permissions
    validate_jobs
    validate_forbidden_references(@document)
    errors
  end

  private

  def validate_triggers
    triggers = @document["on"] || @document[true]
    unless triggers.is_a?(Hash)
      errors << "on must be a mapping"
      return
    end

    names = triggers.keys.map(&:to_s)
    errors << "workflow_dispatch must be the only trigger" unless names == ["workflow_dispatch"]
    errors << "forbidden trigger configured" unless (names & FORBIDDEN_TRIGGERS).empty?

    dispatch = triggers["workflow_dispatch"]
    if dispatch.is_a?(Hash) && dispatch.key?("inputs") && !dispatch["inputs"].nil? && !dispatch["inputs"].empty?
      errors << "workflow_dispatch must not accept inputs"
    end
  end

  def validate_permissions
    errors << "workflow must declare top-level contents: read permissions" unless @document["permissions"] == { "contents" => "read" }
    each_pair(@document) do |key, value|
      next unless key.to_s == "permissions"

      valid = value.is_a?(Hash) && value.values.all? { |permission| READ_ONLY_PERMISSION_VALUES.include?(permission) }
      valid ||= value == "read-all"
      errors << "permissions must be read-only" unless valid
    end
  end

  def validate_jobs
    jobs = @document.fetch("jobs", {})
    errors << "workflow must define exactly one validation job" unless jobs.size == 1

    jobs.each_value do |job|
      errors << "job must not reference a GitHub environment" if job.key?("environment")
      errors << "job must use only the repository-scoped self-hosted labels" unless job["runs-on"] == EXPECTED_RUNNER
      condition = job["if"].to_s.gsub(/\s+/, "")
      errors << "job must be gated before self-hosted execution" unless condition == EXPECTED_JOB_CONDITION
      validate_steps(job.fetch("steps", []))
    end
  end

  def validate_steps(steps)
    checkout_indexes = []
    guard_index = steps.index { |step| step["run"].to_s.include?("EVENT_REF_PROTECTED") }
    sha_check_index = steps.index { |step| step["run"].to_s.include?("git rev-parse HEAD") }
    validation_index = steps.index { |step| step["run"].to_s.include?("brew audit --cask --strict") }

    steps.each_with_index do |step, index|
      if step.key?("uses")
        errors << "only the pinned checkout action is allowed" unless step["uses"] == CHECKOUT_SHA
        checkout_indexes << index
        validate_checkout(step.fetch("with", {}))
      end

      command = step["run"].to_s
      validate_git_commands(command)
      FORBIDDEN_COMMANDS.each do |pattern|
        errors << "forbidden mutating command matches #{pattern.inspect}" if command.match?(pattern)
      end
    end

    errors << "workflow must have one checkout" unless checkout_indexes.size == 1
    checkout_index = checkout_indexes.first
    unless guard_index && checkout_index && guard_index < checkout_index
      errors << "protected branch and event SHA guard must run before checkout"
    end
    unless checkout_index && sha_check_index && validation_index && checkout_index < sha_check_index && sha_check_index < validation_index
      errors << "checked-out SHA must be verified before validation"
    end

    guard = guard_index ? steps[guard_index]["run"].to_s : ""
    errors << "guard must require protected main" unless guard.include?("refs/heads/main") && guard.include?("EVENT_REF_PROTECTED")
    errors << "guard must validate the event SHA" unless guard.include?("EVENT_SHA") && guard.include?("[0-9a-f]{40}")
  end

  def validate_git_commands(command)
    remaining = command.dup
    SAFE_GIT_COMMANDS.each { |pattern| remaining.gsub!(pattern, "") }
    errors << "git command must be in the read-only allowlist" if remaining.match?(/\bgit\b/i)
  end

  def validate_checkout(options)
    allowed = %w[clean persist-credentials ref]
    errors << "checkout contains a repository, path, token, or other unapproved selector" unless (options.keys - allowed).empty?
    errors << "checkout must use only the event SHA" unless options["ref"] == "${{ github.sha }}"
    errors << "checkout credentials must not persist" unless options["persist-credentials"] == false
  end

  def validate_forbidden_references(node)
    case node
    when Hash
      node.each do |key, value|
        key_text = key.to_s
        text = value.is_a?(String) ? value : ""
        errors << "environment references are forbidden" if key_text == "environment"
        errors << "secret references are forbidden" if key_text.match?(SECRET_KEY_PATTERN) || text.match?(SECRET_CONTEXT_PATTERN)
        errors << "hosted runner references are forbidden" if text.match?(/(?:ubuntu|windows|macos)-latest/i)
        errors << "non-default checkout refs are forbidden" if key_text == "ref" && text != "${{ github.sha }}"
        validate_forbidden_references(value)
      end
    when Array
      node.each { |value| validate_forbidden_references(value) }
    end
  end

  def each_pair(node, &block)
    case node
    when Hash
      node.each do |key, value|
        block.call(key, value)
        each_pair(value, &block)
      end
    when Array
      node.each { |value| each_pair(value, &block) }
    end
  end
end

class ManualWorkflowPolicyTest < Minitest::Test
  def policy_for_job(job)
    ManualWorkflowPolicy.new(
      document: {
        "permissions" => { "contents" => "read" },
        "jobs" => { "validate" => job },
      },
    )
  end

  def test_manual_workflow_obeys_security_policy
    assert_empty ManualWorkflowPolicy.new.validate
  end

  def test_job_permissions_cannot_grant_write
    policy = policy_for_job("permissions" => { "contents" => "write" })

    policy.validate

    assert_includes policy.errors, "permissions must be read-only"
  end

  def test_job_write_all_permissions_cannot_grant_write
    policy = policy_for_job("permissions" => "write-all")

    policy.validate

    assert_includes policy.errors, "permissions must be read-only"
  end

  def test_secret_related_keys_are_rejected
    policy = policy_for_job("secret" => "legacy", "secrets" => "inherit")

    policy.validate

    assert_equal 2, policy.errors.count { |error| error == "secret references are forbidden" }
  end

  def test_secret_context_values_are_rejected
    policy = policy_for_job("env" => { "serialized" => "${{ toJSON(secrets) }}" })

    policy.validate

    assert_includes policy.errors, "secret references are forbidden"
  end

  def test_job_gate_cannot_be_broadened_with_or
    policy = policy_for_job(
      "if" => "github.sha != '' || (#{ManualWorkflowPolicy::EXPECTED_JOB_CONDITION})",
      "runs-on" => ManualWorkflowPolicy::EXPECTED_RUNNER,
      "steps" => [],
    )

    policy.validate

    assert_includes policy.errors, "job must be gated before self-hosted execution"
  end

  def test_write_capable_publish_commands_are_rejected
    policy = policy_for_job(
      "steps" => [
        { "run" => "gh api --method POST /repos/example/example" },
        { "run" => "gh api -X POST /repos/example/example" },
        { "run" => "npm publish" },
        { "run" => "gem push" },
      ],
    )

    policy.validate

    assert_equal 4, policy.errors.count { |error| error.start_with?("forbidden mutating command") }
  end

  def test_only_required_read_only_git_commands_are_allowed
    policy = policy_for_job(
      "steps" => [
        { "run" => 'test "$(git rev-parse HEAD)" = "$EVENT_SHA"' },
        { "run" => 'test "$(git branch --show-current)" = ""' },
        { "run" => 'git ls-files --error-unmatch -- "$cask"' },
      ],
    )

    policy.validate

    refute_includes policy.errors, "git command must be in the read-only allowlist"
  end

  def test_git_global_options_and_other_commands_are_rejected
    policy = policy_for_job(
      "steps" => [
        { "run" => 'git -C "$GITHUB_WORKSPACE" checkout main' },
        { "run" => 'git --git-dir="$GITHUB_WORKSPACE/.git" reset --hard' },
        { "run" => "git status --short" },
        { "run" => "git switch main" },
      ],
    )

    policy.validate

    assert_equal 4, policy.errors.count { |error| error == "git command must be in the read-only allowlist" }
  end

  def test_workflow_directory_contains_only_manual_validation
    workflow_files = Dir.glob(File.join(ManualWorkflowPolicy::WORKFLOW_DIR, "*.{yml,yaml}"))
      .map { |path| File.basename(path) }
      .sort

    assert_equal [ManualWorkflowPolicy::WORKFLOW_FILENAME], workflow_files
  end

  def test_manifest_is_explicit_and_covers_every_tracked_cask
    manifest = File.readlines(".github/cask-validation-manifest.txt", chomp: true).reject(&:empty?).sort
    tracked = `git ls-files 'Casks/*.rb'`.lines(chomp: true).sort

    assert $CHILD_STATUS.success?, "could not list tracked casks"
    assert_equal tracked, manifest
    assert manifest.all? { |path| path.match?(%r{\ACasks/[A-Za-z0-9@._+-]+\.rb\z}) }
  end

  def test_manifest_loop_skips_blank_lines_and_processes_final_line_without_newline
    manifest = "Casks/first.rb\n\nCasks/second@beta.rb"

    with_stubbed_validation_commands(manifest) do |command_log|
      commands = File.readlines(command_log, chomp: true)

      assert_equal 8, commands.length
      assert_equal 4, commands.count { |command| command.include?("Casks/first.rb") }
      assert_equal 4, commands.count { |command| command.include?("Casks/second@beta.rb") }
      refute commands.any? { |command| command.end_with?("\t") }
    end
  end

  private

  def with_stubbed_validation_commands(manifest)
    Dir.mktmpdir do |directory|
      bin = File.join(directory, "bin")
      command_log = File.join(directory, "commands.log")
      FileUtils.mkdir_p([bin, File.join(directory, ".github")])
      File.binwrite(File.join(directory, ".github/cask-validation-manifest.txt"), manifest)
      %w[brew git ruby].each { |name| write_command_stub(bin, name) }

      workflow = YAML.safe_load_file(ManualWorkflowPolicy::WORKFLOW, aliases: false)
      validation = workflow.fetch("jobs").fetch("validate-casks").fetch("steps")
        .find { |step| step["name"] == "Validate every manifest cask" }
        .fetch("run")
      environment = { "COMMAND_LOG" => command_log, "PATH" => "#{bin}:#{ENV.fetch('PATH')}" }
      _output, error, status = Open3.capture3(environment, "bash", "-c", validation, chdir: directory)

      assert status.success?, error
      yield command_log
    end
  end

  def write_command_stub(bin, name)
    path = File.join(bin, name)
    File.write(path, <<~BASH)
      #!/bin/bash
      printf '%s' "$(basename "$0")" >> "$COMMAND_LOG"
      printf '\\t%s' "$@" >> "$COMMAND_LOG"
      printf '\\n' >> "$COMMAND_LOG"
    BASH
    FileUtils.chmod(0o755, path)
  end
end
