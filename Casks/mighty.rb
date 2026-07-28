cask "mighty" do
  version "2026.7.13"
  sha256 "fc07ef8c6d7cd97b68a6aeca09f8ca449121f5da89a9aa46effd6fc9bfcee678"

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
