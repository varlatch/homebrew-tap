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
      url "https://github.com/varlatch/varlatch/releases/download/v0.51.0/varlatch-0.51.0-darwin-arm64"
      sha256 "c599078b4365ff6c468e57d5e07d96ae55d61f3378c37c8b478fa4e76978433e"
    end
    on_intel do
      url "https://github.com/varlatch/varlatch/releases/download/v0.51.0/varlatch-0.51.0-darwin-amd64"
      sha256 "800b82a6577a697a4dabe3f3459829f7284edc4a33a1934a7a0e8f635520ae3e"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/varlatch/varlatch/releases/download/v0.51.0/varlatch-0.51.0-linux-arm64"
      sha256 "165addcde9b69d7848a793e2e32d542be2525199c73570cfad3ae8768389c58b"
    end
    on_intel do
      url "https://github.com/varlatch/varlatch/releases/download/v0.51.0/varlatch-0.51.0-linux-amd64"
      sha256 "8480c9ea08164c76fd3bdca7327d6115689c8f43225c1bbfb707e9e91f7bd440"
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
