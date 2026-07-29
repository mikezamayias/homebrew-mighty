cask "mighty" do
  version "2026.7.14"
  sha256 "512c75e12101953660b1a6230186e30ebb19566b8f014b294812358f48fdc77e"

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
