#!/bin/bash
# NeNe Sand installer: downloads the latest release (or NENE_SAND_VERSION), verifies it against SHA256SUMS, then installs it.
#
#   curl -fsSL https://raw.githubusercontent.com/hideyukiMORI/nene-sand/main/install.sh | bash
#
# Installs into ~/.local/bin (override with NENE_SAND_PREFIX). If verification fails, nothing is installed.
set -euo pipefail

repo="hideyukiMORI/nene-sand"
prefix="${NENE_SAND_PREFIX:-$HOME/.local/bin}"
name="nene-sand-linux-x86_64"

fail() {
    echo "nene-sand install: $1" >&2
    exit 1
}

[ "$(uname -s)" = "Linux" ] && [ "$(uname -m)" = "x86_64" ] || fail "only Linux on x86_64 is supported (this is $(uname -s) $(uname -m))"
for tool in curl sha256sum install; do
    command -v "$tool" > /dev/null || fail "$tool is required"
done

version="${NENE_SAND_VERSION:-}"
if [ -z "$version" ]; then
    latest="$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/$repo/releases/latest")"
    version="${latest##*/v}"
fi
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "could not determine the version: $version"

base="https://github.com/$repo/releases/download/v$version"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

echo "nene-sand install: downloading v$version"
curl -fsSL -o "$work/$name" "$base/$name"
curl -fsSL -o "$work/SHA256SUMS" "$base/SHA256SUMS"
(cd "$work" && sha256sum --check --quiet SHA256SUMS) || fail "checksum does not match SHA256SUMS; nothing was installed"
install -Dm755 "$work/$name" "$prefix/nene-sand"

echo "nene-sand install: installed $prefix/nene-sand (v$version)"
case ":$PATH:" in
    *":$prefix:"*) echo "nene-sand install: run nene-sand (q quits and saves the purse)" ;;
    *) echo "nene-sand install: $prefix is not on your PATH; open a new terminal or run export PATH=\"$prefix:\$PATH\"" ;;
esac
