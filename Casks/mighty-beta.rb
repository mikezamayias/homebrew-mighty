cask "mighty-beta" do
  version "2026.7.12"
  sha256 "45389adac52145e6b3149ed16acdcee1dfae4d88c7d00238dd1b83d8ef078751"

  url "https://mighty.mikezamayias.com/downloads/candidates/mighty-#{version}.dmg"
  name "Mighty"
  desc "Beta builds of Mighty (battery, DPI, polling, button remap for Logitech mice)"
  homepage "https://mighty.mikezamayias.com"

  livecheck do
    skip "Beta cask is bumped manually from Candidate releases"
  end

  depends_on macos: :sequoia

  app "Mighty.app"

  caveats <<~EOS
    This is the Mighty beta channel. It installs the same Mighty.app bundle as
    stable, but the DMG comes from /downloads/candidates/ and may be less
    polished than the latest stable cask (`mighty`).

    Do not install both `mighty` and `mighty-beta` at the same time — they
    share the Mighty.app install path.
  EOS

  zap trash: [
    "~/Library/Application Support/Mighty",
    "~/Library/Caches/com.mikezamayias.mighty",
    "~/Library/Preferences/com.mikezamayias.mighty.plist",
  ]
end
