#!/bin/zsh
# Double-click to compile PhotoCraft and launch it for testing (no installer is made).
cd "$(dirname "$0")" || exit 1

# Pick up the same PATH your terminal has (zsh profile + rc), plus the usual cargo locations.
[ -f "$HOME/.zprofile" ] && source "$HOME/.zprofile" 2>/dev/null
[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc" 2>/dev/null
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
export PATH="$HOME/.cargo/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

if ! command -v cargo >/dev/null 2>&1; then
  echo "Rust's cargo was not found on this Mac."
  echo "Install it with:   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
  echo "then run this script again. Press Enter to close."
  read -r
  exit 127
fi

# Use the fonts checkout if it sits next to the repo.
if [ -z "$CRAFT_FONTS_DIR" ] && [ -d "../craft-fonts" ]; then
  export CRAFT_FONTS_DIR="$(cd ../craft-fonts && pwd)"
fi

echo "Building PhotoCraft with $(cargo --version)..."
cargo build --release -p photocraft
status=$?

if [ $status -ne 0 ]; then
  echo
  echo "Build failed (exit $status). Press Enter to close."
  read -r
  exit $status
fi

echo "Build done. Launching target/release/photocraft (this window can be closed)."
nohup ./target/release/photocraft "$@" >/dev/null 2>&1 &
disown
exit 0
