cask "mighty-beta" do
  version "2026.7.12"
  sha256 "45389adac52145e6b3149ed16acdcee1dfae4d88c7d00238dd1b83d8ef078751"

  url "https://mighty.mikezamayias.com/downloads/candidates/mighty-#{version}.dmg"
  name "Mighty (deprecated)"
  desc "Deprecated token — use mighty@beta"
  homepage "https://mighty.mikezamayias.com"

  livecheck do
    skip "Deprecated; use mighty@beta"
  end

  deprecate! date: "2026-07-23", because: "renamed to mighty@beta"

  depends_on macos: :sequoia

  app "Mighty.app"

  caveats <<~EOS
    `mighty-beta` was renamed to `mighty@beta`.

      brew uninstall --cask mighty-beta
      brew install --cask mikezamayias/mighty/mighty@beta

    Both tokens install Mighty.app; do not keep both installed.
  EOS

  zap trash: [
    "~/Library/Application Support/Mighty",
    "~/Library/Caches/com.mikezamayias.mighty",
    "~/Library/Preferences/com.mikezamayias.mighty.plist",
  ]
end
