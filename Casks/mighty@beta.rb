cask "mighty@beta" do
  version "2026.8.1,402"
  sha256 "97517875d9aa7c0c135ab6587bb689062ed125c01a12f10eee3994c6e7f25ae9"

  url "https://mighty.mikezamayias.com/downloads/candidates/mighty-#{version.before_comma}-#{version.after_comma}.dmg"
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

    Do not install both `mighty` and `mighty@beta` at the same time — they
    share the Mighty.app install path.
  EOS

  zap trash: [
    "~/Library/Application Support/Mighty",
    "~/Library/Caches/com.mikezamayias.mighty",
    "~/Library/Preferences/com.mikezamayias.mighty.plist",
  ]
end
