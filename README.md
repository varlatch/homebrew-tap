# Varlatch Homebrew tap

Homebrew formulae for [Varlatch](https://varlatch.com), the self-host-first
secrets and configuration manager.

| Formula | What it installs |
| --- | --- |
| `varlatch` | The `varlatch` CLI, one native binary for your Mac or Linux machine |
| `varlatch-menubar` | [Varlatch for macOS](https://github.com/varlatch/macos-menubar), your sessions in the menu bar, with the CLI |

## Install

The menu bar app, with the CLI:

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

The CLI is the release's native binary for your platform (macOS or Linux,
Apple Silicon or Intel); it needs no Node.js.

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

[`bump-varlatch.yml`](.github/workflows/bump-varlatch.yml) looks for a new
[varlatch/varlatch](https://github.com/varlatch/varlatch/releases) release every
six hours. It checks the release's signature and hash, opens a pull request
that bumps `Formula/varlatch.rb`, and merges it once CI passes.

- **To skip a release,** close its pull request. It is not opened again, and
  the next release gets its own.
- **When CI fails,** the pull request stays open and the scheduled run fails
  until a newer release replaces it or someone deals with it.
- **After 60 days without a commit,** GitHub turns off scheduled workflows in a
  public repository. Turn it back on in the Actions tab; releases normally
  keep this from happening.

To bump by hand, or to redo what the workflow does, for version `X.Y.Z`:

1. Download the release's CLI binaries for macOS and Linux, its checksums,
   and its signature into an empty directory:

   ```bash
   gh release download vX.Y.Z --repo varlatch/varlatch \
     --pattern 'varlatch-X.Y.Z-darwin-*' --pattern 'varlatch-X.Y.Z-linux-*' \
     --pattern 'SHA256SUMS' --pattern 'SHA256SUMS.sigstore.json'
   ```

2. Check the signature on `SHA256SUMS` (needs `cosign`), then the files
   against it:

   ```bash
   cosign verify-blob SHA256SUMS --bundle SHA256SUMS.sigstore.json \
     --certificate-identity "https://github.com/varlatch/varlatch/.github/workflows/release.yml@refs/tags/vX.Y.Z" \
     --certificate-oidc-issuer https://token.actions.githubusercontent.com
   grep -E ' varlatch-X\.Y\.Z-(darwin|linux)-(amd64|arm64)$' SHA256SUMS
   shasum -a 256 varlatch-X.Y.Z-darwin-* varlatch-X.Y.Z-linux-*
   ```

   Each binary's hash must match its line.

3. On a branch, set each of the four `url` lines to the new version, and
   the `sha256` after each to that binary's hash.

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
