cask "mighty" do
  version "2026.6.1"
  sha256 "ee8a26fc8caeb5ab18353a5dacae8d8d4039592d3db5e5ba1f644c0282773fd8"

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
