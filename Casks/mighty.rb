cask "mighty" do
  version "2026.7.2"
  sha256 "c0c6d1fecafeb2c837b921ff22d485dff20d0387d4e0492dee75b48012d410f8"

  url "https://mighty.mikezamayias.com/downloads/mighty-#{version}.dmg"
  name "Mighty"
  desc "Battery status, DPI, polling rate, and button remapping for supported Logitech mice"
  homepage "https://mighty.mikezamayias.com"

  livecheck do
    url "https://github.com/mikezamayias/mighty/releases/latest"
    strategy :page_match do |page|
      page.scan(%r{/mikezamayias/mighty/releases/tag/mighty-(\d{4}\.\d+\.\d+)}i).map(&:first)
    end
  end

  depends_on macos: :sequoia

  app "Mighty.app"

  zap trash: [
    "~/Library/Application Support/Mighty",
    "~/Library/Caches/com.mikezamayias.mighty",
    "~/Library/Preferences/com.mikezamayias.mighty.plist",
  ]
end
