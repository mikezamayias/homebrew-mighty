cask "mighty" do
  version "2026.10.2"
  sha256 "871d2be65427f890d31d438d626b752b0fb7c5b9534521c64a6e539a2e1fb427"

  url "https://mighty.mikezamayias.com/downloads/mighty-#{version}.dmg"
  name "Mighty"
  desc "Battery status, DPI, polling rate, and button remapping for Logitech mice"
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
