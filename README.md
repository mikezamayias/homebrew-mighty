# homebrew-mighty

Mighty, the macOS mouse utility, is discontinued as of October 2026. Downloads at mighty.mikezamayias.com are gone, and this tap is archived.

The `mighty` and `mighty@beta` casks are disabled. `brew install` fails with a discontinued message.

## Uninstall

If Mighty is still installed from this tap:

```bash
brew uninstall --cask mighty
brew untap mikezamayias/mighty
```

`mighty@beta` installs the same `Mighty.app`. If you installed the beta cask, uninstall that cask before untapping:

```bash
brew uninstall --cask mighty@beta
brew untap mikezamayias/mighty
```

## Validation policy

This public repository intentionally does not run automatic checks for pull requests, pushes, or schedules.
Public pull requests therefore receive no automatic CI results.
The manual workflow validates only code that has already landed on the protected `main` branch, so its result does not validate pull request code.
That workflow is unchanged.

Only the Captain may start a validation run, and only after the repository changes to validate have landed on `main`.
The separately registered repository-scoped runner must have the labels `self-hosted`, `macOS`, `ARM64`, and `homebrew-mighty-manual`.
Default-branch protection and runner registration are account operations maintained separately from this repository.
The registered-offline runner operating model and protected `main` prerequisite must be confirmed through read-only account inspection before dispatch.
The Captain must complete any pending account follow-up and bring the registered runner online before dispatch; this repository does not register or start runners or mutate account settings.

The Captain's dispatch procedure is:

1. Open the repository's **Actions** tab and select **Manual cask validation**.
2. Select **Run workflow** and confirm the branch shown is `main`.
3. Confirm there are no workflow inputs, then select **Run workflow**.
4. Confirm the run SHA is the expected landed `main` commit and review every validation result.

The workflow checks Ruby syntax, Homebrew style, and strict cask audit results for every path in `.github/cask-validation-manifest.txt`.
It has read-only GitHub permissions and does not install casks, publish releases, update casks, push commits, open pull requests, or call Mighty workflows.
Homebrew commands may create unavoidable local command caches on the attended runner.

The immutable Nix Homebrew boundary applies to local validation as well.
Do not install vendor gems globally or mutate Homebrew to work around this limitation.
When the Nix-store Homebrew vendor bundle is read-only, local `brew style` and `brew audit --cask --strict` cannot complete because the non-mutating `HOMEBREW_TESTS` workaround lacks `rubocop` and `rubocop-ast`.
Record that limitation in the PR report.

There is no Codemagic workflow or executable Codemagic integration in this repository.
