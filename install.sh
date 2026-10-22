#!/usr/bin/env bash
# install.sh — deploy rm-send + sanity-check dependencies
set -e
DIR="$(dirname "$(readlink -f "$0")")"

# 1) deploy shim + source onto PATH
mkdir -p "$HOME/.local/bin"
ln -sf "$DIR/rm-send" "$HOME/.local/bin/rm-send"
echo "✓ installed: $HOME/.local/bin/rm-send -> $DIR/rm-send"

# 1b) default config file (never overwrites an existing one)
CONFIG="$HOME/.config/rm-send.toml"
if [ ! -e "$CONFIG" ]; then
  mkdir -p "$(dirname "$CONFIG")"
  cp "$DIR/config.example.toml" "$CONFIG"
  echo "✓ created config: $CONFIG (edit sizes/folder to taste)"
else
  echo "• existing config left untouched: $CONFIG"
fi

# 2) dependency check
missing=""
for t in python3 typst wl-paste notify-send; do
  command -v "$t" >/dev/null 2>&1 || missing="$missing $t"
done
[ -n "$(command -v xclip)" ] && true
if [ -n "$missing" ]; then
  echo "⚠ missing:$missing"
  echo "  linux:  sudo pacman -S python typst wl-clipboard libnotify  (xclip for X11)"
  echo "  mac:    brew install typst pngpaste"
else
  echo "✓ all core dependencies present"
fi

# 3) optional extras (informational only)
command -v rmapi   >/dev/null 2>&1 && echo "✓ rmapi found — cloud transport enabled (auth with: rm-send --auth)" || echo "• no rmapi — cloud disabled (download from ddvk/rmapi releases onto PATH, then: rm-send --auth)"
command -v pngpaste >/dev/null 2>&1 && echo "✓ pngpaste found (macOS clipboard images)" || true
command -v xclip   >/dev/null 2>&1 && echo "✓ xclip found (X11 fallback)" || true

# 4) SSH reachability check (USB transport)
if [ -t 1 ]; then
  ssh -o ConnectTimeout=4 -o BatchMode=yes root@10.11.99.1 echo >/dev/null 2>&1 \
    && echo "✓ tablet reachable over USB (SSH key works)" \
    || echo "• tablet not reachable (USB offline or key missing) — USB transport disabled"
fi
