cask "mighty@beta" do
  version "2026.8.1"
  sha256 "4084ac12a21478e615f8999030f1109443ca71bec51aa29879db8a71e2c2565b"

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

    Do not install both `mighty` and `mighty@beta` at the same time — they
    share the Mighty.app install path.
  EOS

  zap trash: [
    "~/Library/Application Support/Mighty",
    "~/Library/Caches/com.mikezamayias.mighty",
    "~/Library/Preferences/com.mikezamayias.mighty.plist",
  ]
end
