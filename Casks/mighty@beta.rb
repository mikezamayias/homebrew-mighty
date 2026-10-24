cask "mighty@beta" do
  version "2026.8.1,404"
  sha256 "3fe5ebaf2d7115ddede934945ff7418718edf612f4a088b8b1f1f610c3d0e7c4"

  url "https://mighty.mikezamayias.com/downloads/candidates/mighty-#{version.csv.first}-#{version.csv.second}.dmg"
  name "Mighty"
  desc "Beta builds of Mighty (battery, DPI, polling, button remap for Logitech mice)"
  homepage "https://mighty.mikezamayias.com/"

  disable! date: "2026-10-24", because: :discontinued

  depends_on macos: :sequoia

  app "Mighty.app"

  zap trash: [
    "~/Library/Application Support/Mighty",
    "~/Library/Caches/com.mikezamayias.mighty",
    "~/Library/Preferences/com.mikezamayias.mighty.plist",
  ]
end
