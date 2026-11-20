class Varlatch < Formula
  desc "Self-host-first secrets and configuration manager CLI"
  homepage "https://varlatch.com"
  license "Apache-2.0"

  # The Go CLI, one native binary per platform (varlatch/varlatch ADR-0059).
  # Each sha256 is the file's line in the release's SHA256SUMS, whose
  # Sigstore signature bump-varlatch.yml checks before it changes them.
  on_macos do
    on_arm do
      url "https://github.com/varlatch/varlatch/releases/download/v0.50.0-rc.1/varlatch-0.50.0-rc.1-darwin-arm64"
      sha256 "495bd8c998dfbc50386d677a8ef00c207f47a096fedf519495a3760dba693c90"
    end
    on_intel do
      url "https://github.com/varlatch/varlatch/releases/download/v0.50.0-rc.1/varlatch-0.50.0-rc.1-darwin-amd64"
      sha256 "420d0dd908cbb1265cb6e614cfc62e59167b7166d16b20b1e649c9c5d0d8f9ca"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/varlatch/varlatch/releases/download/v0.50.0-rc.1/varlatch-0.50.0-rc.1-linux-arm64"
      sha256 "c5cdb65999c3466cee431c5e3a5cdee9a59bcecde1316ac04fdeec808237190f"
    end
    on_intel do
      url "https://github.com/varlatch/varlatch/releases/download/v0.50.0-rc.1/varlatch-0.50.0-rc.1-linux-amd64"
      sha256 "c8e02b06f7330b9cef071dfd0fcb519c18f760bc40276ef1603b404f206f0f99"
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

  test do
    assert_match version.to_s, shell_output("#{bin}/varlatch --version")

    ENV["VARLATCH_CONFIG_DIR"] = testpath
    assert_match '"servers":[]', shell_output("#{bin}/varlatch status --json").gsub(/\s/, "")

    assert_match "brew upgrade varlatch", shell_output("#{bin}/varlatch self-update 2>&1", 1)
  end
end
