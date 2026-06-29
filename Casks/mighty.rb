cask "mighty" do
  version "2026.6.5"
  sha256 "36d886f6e5c4cd7b9cecf9fc6541fcf36de0712de90bf48edc5f27fb16ade4de"

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
    "~/Library/Preferences/com.mikezamayias.mighty.Sparkle.plist",
    "~/Library/Preferences/com.mikezamayias.mighty.plist",
  ]
end
