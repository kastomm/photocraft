#!/bin/zsh
# Double-click to build the PhotoCraft.app installer (Apple Silicon, ad-hoc signed) into installers/.
cd "$(dirname "$0")" || exit 1

[ -f "$HOME/.zprofile" ] && source "$HOME/.zprofile" 2>/dev/null
[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc" 2>/dev/null
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
export PATH="$HOME/.cargo/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

if ! command -v cargo >/dev/null 2>&1; then
  echo "Rust's cargo was not found. Install it with:"
  echo "   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
  echo "Press Enter to close."; read -r; exit 127
fi

if [ -z "$CRAFT_FONTS_DIR" ] && [ -d "../craft-fonts" ]; then
  export CRAFT_FONTS_DIR="$(cd ../craft-fonts && pwd)"
fi

case "$(uname -m)" in
  arm64) ARCH=aarch64 ;;
  *) ARCH=x86_64 ;;
esac

OUT="$PWD/installers"
mkdir -p "$OUT"

echo "Packaging PhotoCraft.app for macOS ($ARCH) into installers/..."
DIST="$OUT" packaging/macos/package.sh --arch "$ARCH"
status=$?

if [ $status -ne 0 ]; then
  echo; echo "Packaging failed (exit $status). Press Enter to close."; read -r; exit $status
fi

# Put the bare .app next to the DMG too, so it can be dragged straight to Applications.
rm -rf "$OUT/PhotoCraft.app"
ditto target/macos-package/PhotoCraft.app "$OUT/PhotoCraft.app"

echo
echo "Done. PhotoCraft.app and the DMG are in installers/."
open "$OUT"
