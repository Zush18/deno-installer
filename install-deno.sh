#!/bin/sh
# Copyright 2019 the Deno authors. All rights reserved. MIT license.
# TODO(everyone): Keep this script simple and easily auditable.
# Modified by Oziel Cortés Piña on 2020 under the MIT licence terms

set -e

case $(uname -s) in
Darwin) target="x86_64-apple-darwin" ;;
*) target="x86_64-unknown-linux-gnu" ;;
esac

if [ $(uname -m) != "x86_64" ]; then
	echo "Unsupported architecture $(uname -m). Only x64 binaries are available."
	exit
fi

if [ $# -eq 0 ]; then
	deno_asset_path=$(
		command curl -sSf https://github.com/denoland/deno/releases |
			command grep -o "/denoland/deno/releases/download/.*/deno-${target}\\.zip" |
			command head -n 1
	)
	if [ ! "$deno_asset_path" ]; then exit 1; fi
	deno_uri="https://github.com${deno_asset_path}"
else
	deno_uri="https://github.com/denoland/deno/releases/download/${1}/deno-${target}.zip"
fi

deno_install="${DENO_INSTALL:-$HOME/.local}"
bin_dir="$deno_install/bin"
exe="$bin_dir/deno"

if [ ! -d "$bin_dir" ]; then
	mkdir -p "$bin_dir"
fi

curl --fail --location --progress-bar --output "$exe.zip" "$deno_uri"
cd "$bin_dir"
unzip -o "$exe.zip"
chmod +x "$exe"
rm "$exe.zip"

echo "Deno was installed successfully to $exe"
if command -v deno >/dev/null; then
	echo "Run 'deno --help' to get started"
else
	echo "Manually add the directory to your \$HOME/.profile (or similar). Its recomended that if \$HOME/.profile (or similar) exists just re-start your profile (logout and login). The next command adds the bin path to your \$PATH for a shell session"
	echo "  export PATH=\"$exe:\$PATH\""
	echo "Run '$exe --help' to get started"
fi
