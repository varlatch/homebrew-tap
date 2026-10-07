# Varlatch Homebrew tap

Homebrew formulae for [Varlatch](https://varlatch.com), the self-host-first
secrets and configuration manager.

| Formula | What it installs |
| --- | --- |
| `varlatch` | The `varlatch` CLI, run with Homebrew's Node.js |

## Install

```bash
brew install varlatch/tap/varlatch
varlatch --version
```

This installs Node.js from Homebrew when you do not have it yet. The CLI
always runs with Homebrew's `node`, whatever is first on your `PATH`.

Then sign in to your server:

```bash
varlatch login --server https://varlatch.example.com
```

## Upgrade

```bash
brew update
brew upgrade varlatch
```

Homebrew owns the installed files, so a Homebrew CLI refuses
`varlatch self-update` and points you to `brew upgrade varlatch` instead.

## Uninstall

```bash
brew uninstall varlatch
brew untap varlatch/tap
```

Uninstalling leaves your sign-ins in `~/.config/varlatch/`. Run
`varlatch logout --server <url>` first to revoke a credential on its
server, or delete that directory to forget them locally.

## Maintaining the formulae

### A new Varlatch release

Each release of [varlatch/varlatch](https://github.com/varlatch/varlatch/releases)
needs a bump of `Formula/varlatch.rb`. For version `X.Y.Z`:

1. Download the release's CLI, checksums, and signature into an empty
   directory:

   ```bash
   gh release download vX.Y.Z --repo varlatch/varlatch \
     --pattern 'varlatch-cli-X.Y.Z.cjs' --pattern 'SHA256SUMS' \
     --pattern 'SHA256SUMS.sigstore.json'
   ```

2. Check the signature on `SHA256SUMS` (needs `cosign`), then the file
   against it:

   ```bash
   cosign verify-blob SHA256SUMS --bundle SHA256SUMS.sigstore.json \
     --certificate-identity "https://github.com/varlatch/varlatch/.github/workflows/release.yml@refs/tags/vX.Y.Z" \
     --certificate-oidc-issuer https://token.actions.githubusercontent.com
   grep ' varlatch-cli-X.Y.Z.cjs$' SHA256SUMS
   shasum -a 256 varlatch-cli-X.Y.Z.cjs
   ```

   The two hashes must match.

3. On a branch, set `url` to the new version and `sha256` to that hash.

4. Check it locally, with this checkout as the tap:

   ```bash
   brew style varlatch/tap
   brew audit --strict --online varlatch/tap/varlatch
   brew reinstall --build-from-source varlatch/tap/varlatch
   brew test varlatch/tap/varlatch
   ```

5. Open a pull request. CI runs the same checks on a macOS runner; merge
   once it passes.

### Working on a checkout

`brew tap` clones the tap, so to try changes before they are pushed, put a
link to your checkout in its place:

```bash
tap="$(brew --repository)/Library/Taps/varlatch/homebrew-tap"
rm -rf "$tap" && mkdir -p "$(dirname "$tap")" && ln -s "$PWD" "$tap"
```

To go back to the published tap, remove the link (`rm "$tap"`) and run
`brew tap varlatch/tap`.

## License

Copyright © 2026 Robotsson. Licensed under the Apache License 2.0; see
[`LICENSE`](LICENSE).
