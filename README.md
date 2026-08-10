# homebrew-mighty

Homebrew tap for [Mighty](https://mighty.mikezamayias.com).

## Install

```bash
# Stable
brew install --cask mikezamayias/mighty/mighty

# Beta / Candidate channel
brew install --cask mikezamayias/mighty/mighty@beta
```

`mighty@beta` installs the same `Mighty.app` as stable, but downloads from
`https://mighty.mikezamayias.com/downloads/candidates/`.
Do not install both casks at the same time.

## Validation policy

This public repository intentionally does not run automatic checks for pull requests, pushes, or schedules.
Public pull requests therefore receive no automatic CI results.
The manual workflow validates only code that has already landed on the protected `main` branch, so its result does not validate pull request code.

Only the Captain may start a validation run, and only after the repository changes to validate have landed on `main`.
The separately registered repository-scoped runner must have the labels `self-hosted`, `macOS`, `ARM64`, and `homebrew-mighty-manual`.
Default-branch protection and runner registration are account operations maintained separately from this repository.
The latest read-only `gh-axi` inspection found the repository-scoped runner registered but offline, while default-branch protection remains a pending account action.
The Captain must protect `main` and bring the registered runner online before dispatch; this repository does not register or start runners or mutate account settings.

The Captain's dispatch procedure is:

1. Open the repository's **Actions** tab and select **Manual cask validation**.
2. Select **Run workflow** and confirm the branch shown is `main`.
3. Confirm there are no workflow inputs, then select **Run workflow**.
4. Confirm the run SHA is the expected landed `main` commit and review every validation result.

The workflow checks Ruby syntax, Homebrew style, and strict cask audit results for every path in `.github/cask-validation-manifest.txt`.
It has read-only GitHub permissions and does not install casks, publish releases, update casks, push commits, open pull requests, or call Mighty workflows.
Homebrew commands may create unavoidable local command caches on the attended runner.
Mighty remains the sole owner of cask publishing and mirror mutations.

The immutable Nix Homebrew boundary applies to local validation as well.
Local `brew style` and `brew audit --cask --strict` attempts were blocked because the Nix-store Homebrew vendor bundle is read-only, and the non-mutating `HOMEBREW_TESTS` workaround lacks `rubocop` and `rubocop-ast`.
Do not install vendor gems globally or mutate Homebrew to work around this limitation.

There is no Codemagic workflow or executable Codemagic integration in this repository.
