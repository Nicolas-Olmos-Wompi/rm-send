# rm-send — clipboard → reMarkable tablet

Sends your Linux/macOS clipboard (text **or** image) to a reMarkable tablet as a
native document named `zz Inbox · … (text|image)`, sorted into a `zz Inbox`
library folder.

- **Text** (code, paragraphs) → formatted page-matched PDF
- **Image** (screenshots, copied pictures) → PNG placed full-page
- Auto-detects what's on the clipboard (image wins if present)

## Setup

```bash
rm-send --auth      # one-time: paste the 8-char code from
                    # https://my.remarkable.com/device/browser/connect
```

Stores nothing in the repo — the device token lands in `~/.config/rmapi/rmapi.conf`
(gitignored). To copy your auth to another machine, either copy that file or run
`--auth` there with a fresh code. To revoke: remove the device in your
reMarkable account settings, or delete the conf file.

## Transports

| Transport | Behavior | Needs |
|---|---|---|
| `--cloud` (default) | rmapi → reMarkable cloud → `rm-sync` pulls it in silently. **No restart, screen never flashes** | `rm-send --auth` once + tablet WiFi on |
| `--usb` | Direct SSH injection into xochitl's document store + restart | SSH key to tablet root (USB: `10.11.99.1`) |

Cloud is used automatically when configured; USB is the offline/private fallback.

## Install

Linux (Omarchy / any Wayland distro):

```bash
./install.sh
```

Requirements: `python3`, `typst`, `wl-clipboard` (or `xclip`), optionally `rmapi`
(for cloud) and SSH access to the tablet (for USB).

macOS: copy `rm-send.py` anywhere, then `pip3 install`-free — you need `typst`
(`brew install typst`) and `pngpaste` (`brew install pngpaste`). `rmapi` for
cloud (`brew install rmapi`).

## Usage

```bash
rm-send            # copy anything, then press/run
rm-send --usb      # force the offline USB transport
rm-send --cloud    # force the cloud transport
```

Or bind to a key. On Hyprland (Omarchy):
`o.bind("SUPER + SHIFT + I", "reMarkable: send clipboard", "rm-send")`

## Safety

- Backs up the tablet's entire document store (once per day) to `~/rm-backups/`
  before first write
- Never patches or replaces `/usr/bin/xochitl` — it only adds documents
- One-command rollback: empty the Inbox folder / restore the backup

## Secrets / auth

Auth is handled by `rmapi` (triggered via `rm-send --auth`); `rm-send.py` itself
contains zero credentials. `~/.config/rmapi/rmapi.conf` holds your account's
device token — never commit or share it.
