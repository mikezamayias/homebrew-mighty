cask "mighty" do
  version "2026.6.0"
  sha256 "e3e93bb1c588c75fc8bb4e3c4f158c5cebfbb11386b5a18d537d7f928b4a852f"

  url "https://mighty.mikezamayias.com/downloads/mighty-#{version}.dmg"
  name "Mighty"
  desc "Mightier than G HUB. — battery, DPI, polling rate, button remapping for your Logitech mouse"
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
