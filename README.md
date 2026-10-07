# Varlatch Homebrew tap

Homebrew formulae for [Varlatch](https://varlatch.com), the self-host-first
secrets and configuration manager.

| Formula | What it installs |
| --- | --- |
| `varlatch` | The `varlatch` CLI, run with Homebrew's Node.js |
| `varlatch-menubar` | [Varlatch for macOS](https://github.com/varlatch/macos-menubar), your sessions in the menu bar, with the CLI |

## Install

The menu bar app, with the CLI and Node.js:

```bash
brew install varlatch/tap/varlatch varlatch/tap/varlatch-menubar
mkdir -p ~/Applications
ln -sfn "$(brew --prefix)/opt/varlatch-menubar/Varlatch.app" ~/Applications/Varlatch.app
open ~/Applications/Varlatch.app
```

Homebrew loads formulae from a tap like this one only once you trust them,
and installing a formula by its full name trusts it. The app needs the CLI,
so name both; `brew install varlatch/tap/varlatch-menubar` alone stops at
"Refusing to load formula varlatch/tap/varlatch from untrusted tap". To
trust every formula in this tap instead, run `brew trust varlatch/tap`
first.

Homebrew builds the app from source on your Mac with Apple's Command Line
Tools (Xcode is not needed), so it opens without a Gatekeeper prompt.
Homebrew cannot write to `/Applications`; the link in `~/Applications`
makes the app show in Finder, Spotlight, and Launchpad, and follows
upgrades. Needs macOS 13 or newer.

Only the CLI:

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
brew upgrade varlatch varlatch-menubar
```

The app (0.2.0 and newer) notices the upgrade and offers to restart into
the new version. With 0.1.0 still running, quit it and open it again once.

Homebrew owns the installed files, so a Homebrew CLI refuses
`varlatch self-update` and points you to `brew upgrade varlatch` instead.

## Uninstall

Turn off **Open at login** in the app's Settings first, quit it, then:

```bash
brew uninstall varlatch-menubar varlatch
rm ~/Applications/Varlatch.app
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

### A new release of the menu bar app

Once CI has passed on the commit and `vX.Y.Z` is tagged and released in
[varlatch/macos-menubar](https://github.com/varlatch/macos-menubar/releases):

1. Hash the tag's source tarball:

   ```bash
   curl -fsSL https://github.com/varlatch/macos-menubar/archive/refs/tags/vX.Y.Z.tar.gz | shasum -a 256
   ```

2. On a branch, set `url` in `Formula/varlatch-menubar.rb` to the new tag
   and `sha256` to that hash.

3. Check it as above (`brew style`, `brew audit --strict --online`,
   `brew reinstall --build-from-source varlatch/tap/varlatch-menubar`,
   `brew test`), open a pull request, and merge once CI passes.

`brew install --HEAD varlatch/tap/varlatch-menubar` builds the latest
`main` instead, for trying unreleased changes.

### Working on a checkout

`brew tap` clones the tap, so to try changes before they are pushed, put a
link to your checkout in its place:

```bash
tap="$(brew --repository)/Library/Taps/varlatch/homebrew-tap"
rm -rf "$tap" && mkdir -p "$(dirname "$tap")" && ln -s "$PWD" "$tap"
brew trust varlatch/tap
```

To go back to the published tap, remove the link (`rm "$tap"`) and run
`brew tap varlatch/tap`.

## License

Copyright © 2026 Robotsson. Licensed under the Apache License 2.0; see
[`LICENSE`](LICENSE).
