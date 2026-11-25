class Varlatch < Formula
  desc "Self-host-first secrets and configuration manager CLI"
  homepage "https://varlatch.com"
  license "Apache-2.0"

  # The Go CLI, one native binary per platform (varlatch/varlatch ADR-0059).
  # Each sha256 is the file's line in the release's SHA256SUMS, whose
  # Sigstore signature bump-varlatch.yml checks before it changes them.
  on_macos do
    on_arm do
      url "https://github.com/varlatch/varlatch/releases/download/v0.50.0/varlatch-0.50.0-darwin-arm64"
      sha256 "27caebb548eb1c1b8ec3fc2c255c71dc5ce775dcca58a27efe8e50f13b5ca6af"
    end
    on_intel do
      url "https://github.com/varlatch/varlatch/releases/download/v0.50.0/varlatch-0.50.0-darwin-amd64"
      sha256 "b1fcbd5968da1dc9b631ce1417217ea35a7c0ea350a1e95b5cbb5f65325a8e42"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/varlatch/varlatch/releases/download/v0.50.0/varlatch-0.50.0-linux-arm64"
      sha256 "9b452c1dc9a2bd6f8dd8acbdec33d693146cd3758b4d8ed3a897ad1ad169d144"
    end
    on_intel do
      url "https://github.com/varlatch/varlatch/releases/download/v0.50.0/varlatch-0.50.0-linux-amd64"
      sha256 "8c6b311df899feab561f8ff5fc3972b81cf6fd7e2995f845d1cd662666f65bca"
    end
  end

  livecheck do
    url :stable
    strategy :github_latest
  end

  def install
    os = OS.mac? ? "darwin" : "linux"
    arch = Hardware::CPU.arm? ? "arm64" : "amd64"
    # Homebrew owns this file: `brew upgrade` updates it, and the CLI's
    # self-update sees it under the Cellar and points there.
    bin.install "varlatch-#{version}-#{os}-#{arch}" => "varlatch"
  end

  def caveats
    <<~EOS
      varlatch is now one native binary and no longer needs Node.js.
      If nothing else uses it, `brew autoremove` removes the node an
      earlier varlatch pulled in.

      `varlatch self-update` refuses for a Homebrew install; upgrade with
        brew upgrade varlatch
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/varlatch --version")

    ENV["VARLATCH_CONFIG_DIR"] = testpath
    assert_match '"servers":[]', shell_output("#{bin}/varlatch status --json").gsub(/\s/, "")

    assert_match "brew upgrade varlatch", shell_output("#{bin}/varlatch self-update 2>&1", 1)
  end
end
