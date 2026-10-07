class VarlatchMenubar < Formula
  desc "Varlatch sessions in the macOS menu bar"
  homepage "https://varlatch.com"
  url "https://github.com/varlatch/macos-menubar/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "bbb641573394d2dad7aba499c29f1b394ca2d720fab05c966f0be94980956cb4"
  license "Apache-2.0"
  head "https://github.com/varlatch/macos-menubar.git", branch: "main"

  depends_on macos: :ventura
  depends_on "varlatch/tap/varlatch"

  def install
    # A HEAD build takes its version from the latest tag in its checkout.
    args = ["--output", buildpath/"build"]
    args += ["--version", version.to_s] if build.stable?
    # Homebrew's build sandbox does not allow SwiftPM's own.
    system "scripts/bundle.sh", *args, "--", "--disable-sandbox"
    prefix.install "build/Varlatch.app"
  end

  def caveats
    <<~EOS
      To open Varlatch from Finder, Spotlight, and Launchpad, link it into
      ~/Applications once:
        mkdir -p ~/Applications
        ln -sfn #{opt_prefix}/Varlatch.app ~/Applications/Varlatch.app
        open ~/Applications/Varlatch.app
      The link follows `brew upgrade`. After an upgrade, quit Varlatch and
      open it again.

      Before uninstalling, turn off "Open at login" in Varlatch's Settings.
    EOS
  end

  test do
    app = prefix/"Varlatch.app"
    assert_path_exists app/"Contents/MacOS/Varlatch"
    plist = app/"Contents/Info.plist"
    assert_equal "com.varlatch.menubar",
                 shell_output("/usr/bin/plutil -extract CFBundleIdentifier raw #{plist}").chomp
    if build.stable?
      assert_equal version.to_s,
                   shell_output("/usr/bin/plutil -extract CFBundleShortVersionString raw #{plist}").chomp
    end
    system "/usr/bin/codesign", "--verify", "--strict", app
  end
end
