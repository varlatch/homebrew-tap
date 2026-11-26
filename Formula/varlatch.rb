class Varlatch < Formula
  desc "Self-host-first secrets and configuration manager CLI"
  homepage "https://varlatch.com"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  # The Go CLI, one native binary per platform (varlatch/varlatch ADR-0059).
  # Each sha256 is the file's line in the release's SHA256SUMS, whose
  # Sigstore signature bump-varlatch.yml checks before it changes them.
  on_macos do
    on_arm do
      url "https://github.com/varlatch/varlatch/releases/download/v0.50.2/varlatch-0.50.2-darwin-arm64"
      sha256 "e6c0a782ae53f168f0a74a2e520b228d134c9ede69a5efb25a8c915dd4d9cc3b"
    end
    on_intel do
      url "https://github.com/varlatch/varlatch/releases/download/v0.50.2/varlatch-0.50.2-darwin-amd64"
      sha256 "7794bfd5e2263c905b493189ee7d1fb04fd25488bc1f6b8108d7c8c57dfa08ea"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/varlatch/varlatch/releases/download/v0.50.2/varlatch-0.50.2-linux-arm64"
      sha256 "8e0e46f3bf1bbbb63c15076a8f09c29018b85a8ede684a281d1fe787b7f01e6f"
    end
    on_intel do
      url "https://github.com/varlatch/varlatch/releases/download/v0.50.2/varlatch-0.50.2-linux-amd64"
      sha256 "c05d7d09b2d8563c4b4623c85c14bd01b858d85a2d6aad39952847f9e6b487d5"
    end
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
