class Varlatch < Formula
  desc "Self-host-first secrets and configuration manager CLI"
  homepage "https://varlatch.com"
  url "https://github.com/varlatch/varlatch/releases/download/v0.17.3/varlatch-cli-0.17.3.cjs"
  sha256 "a82a24d733bab2de94bd042f53fa5c67374ae331bc971763a49eadc791835d66"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "node"

  def install
    libexec.install "varlatch-cli-#{version}.cjs" => "varlatch.cjs"
    # Run with Homebrew's node whatever the PATH. Homebrew owns this file, so
    # `brew upgrade` updates it rather than `varlatch self-update`.
    (bin/"varlatch").write <<~SH
      #!/bin/bash
      if [ "$1" = "self-update" ]; then
        echo "varlatch: installed with Homebrew; update with: brew upgrade varlatch" >&2
        exit 1
      fi
      exec "#{formula_opt_bin("node")}/node" "#{libexec}/varlatch.cjs" "$@"
    SH
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/varlatch --version")

    ENV["VARLATCH_CONFIG_DIR"] = testpath
    assert_match '"servers":[]', shell_output("#{bin}/varlatch status --json").gsub(/\s/, "")

    assert_match "brew upgrade varlatch", shell_output("#{bin}/varlatch self-update 2>&1", 1)
  end
end
