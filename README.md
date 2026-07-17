# sway-configs-arch

A minimal, dark, blurry [SwayFX](https://github.com/WillPower3309/swayfx) desktop for Arch Linux / CachyOS — inspired by the Fedora Sway Spin, but cleaner and faster. Neon-blue-on-dark-navy palette (Tokyo Night colors) applied consistently across the window manager, bar, launcher, notifications, and lockscreen.

> **Note:** these configs require **SwayFX**, not vanilla sway, for blur, rounded corners, and shadows. SwayFX is a drop-in fork with the same config syntax. If you want vanilla sway, delete the block marked `[SWAYFX ONLY]` in `sway/config`.

## What's inside

| Component | Role | Config |
|---|---|---|
| [SwayFX](https://github.com/WillPower3309/swayfx) | Window manager (blur, rounded corners, shadows) | [sway/config](sway/config) |
| [Alacritty](https://github.com/alacritty/alacritty) | Terminal (Nord palette, FiraCode Nerd Font) | [alacritty/alacritty.toml](alacritty/alacritty.toml) |
| [Starship](https://starship.rs) | Shell prompt (bracketed-segments preset, generated at install) | `~/.config/starship/alacritty.toml` |
| [Waybar](https://github.com/Alexays/Waybar) | Status bar | [waybar/](waybar/) |
| [Wofi](https://hg.sr.ht/~scoopta/wofi) | App launcher + power menu | [wofi/](wofi/) |
| [Mako](https://github.com/emersion/mako) | Notifications | [mako/config](mako/config) |
| awww (swww) | Wallpaper daemon with fade transitions | [awww/wallpaper.sh](awww/wallpaper.sh) |
| swaylock-effects | Themed lockscreen with keyboard-layout indicator | [sway/scripts/lock.sh](sway/scripts/lock.sh) |
| grim + slurp | Screenshots (output / region / window) | [sway/scripts/screenshot.sh](sway/scripts/screenshot.sh) |
| [Spectacle](https://apps.kde.org/spectacle/) | KDE screenshot tool on `$mod+Shift+S` (Windows-style snipping) | — |

Helper scripts live in [sway/scripts/](sway/scripts/): launcher toggle ([menu.sh](sway/scripts/menu.sh)), power menu ([powermenu.sh](sway/scripts/powermenu.sh)), lockscreen ([lock.sh](sway/scripts/lock.sh)), screenshots ([screenshot.sh](sway/scripts/screenshot.sh)).

## Install

```sh
git clone https://github.com/shahinabdi/sway-configs-arch.git
cd sway-configs-arch
./install.sh
```

The installer:

- installs missing packages from the official repos, and from the AUR via `yay`/`paru` if available (`swayfx`, `awww`, …),
- backs up any existing `~/.config/{sway,waybar,mako,awww,wofi,alacritty}` to `~/.config-backup-<timestamp>` — nothing is silently overwritten,
- copies the configs into `~/.config` and marks the scripts executable,
- creates `~/Pictures/Wallpapers` and `~/Pictures/Screenshots`, installing the bundled `current.jpg` as wallpaper if you don't have one yet (existing wallpapers are never replaced),
- generates the Starship [bracketed-segments](https://starship.rs/presets/bracketed-segments) preset at `~/.config/starship/alacritty.toml` and enables it in `~/.bashrc` (skipped if already present).

Flags:

```sh
./install.sh --symlink         # symlink configs into ~/.config instead of copying
./install.sh --no-pkgs         # skip package installation, only deploy configs
./install.sh --dry-run         # print what would happen, change nothing
./install.sh --layout=qwerty   # skip the keyboard-layout prompt (azerty|qwerty)
```

After installing:

1. The bundled wallpaper lands at `~/Pictures/Wallpapers/current.jpg` — replace that file to use your own.
2. Check your output name with `swaymsg -t get_outputs` and adjust the `output *` lines in `sway/config` if needed.
3. Log into a Sway session (or run `sway` from a TTY).

## Keybindings

The repo config is **French (AZERTY)** — `xkb_layout fr`, workspace keys `&é"'(-è_çà`. The installer asks which layout you use and, if you answer `qwerty`, converts the deployed config to `xkb_layout us` with workspace keys `1-0`. You can skip the prompt with `./install.sh --layout=qwerty` (or `--layout=azerty`); non-interactive runs keep AZERTY. For other layouts, edit `xkb_layout` in `sway/config` yourself.

`$mod` is the Super/Windows key.

| Keys | Action |
|---|---|
| `$mod+Return` | Terminal (alacritty) |
| `$mod+d` | App launcher (wofi, toggles) |
| `$mod+q` | Close window |
| `$mod+Shift+e` | Power menu |
| `$mod+Shift+x` | Lock screen |
| `$mod+Shift+c` | Reload sway config |
| `$mod+h/j/k/l` or arrows | Focus window |
| `$mod+Shift+h/j/k/l` or arrows | Move window |
| `$mod+1…0` (AZERTY row) | Switch workspace |
| `$mod+Shift+1…0` | Move window to workspace and follow |
| `$mod+s` / `$mod+w` / `$mod+e` | Stacking / tabbed / split layout |
| `$mod+f` | Fullscreen |
| `$mod+Shift+Space` | Toggle floating |
| `$mod+r` | Resize mode |
| `Print` / `$mod+Print` / `$mod+Shift+Print` | Screenshot output / region / window (grim + slurp) |
| `$mod+Shift+s` | Region screenshot with KDE Spectacle, copied to clipboard |
| `XF86Audio*` / `XF86MonBrightness*` | Volume, media, brightness keys |

Idle behavior: the screen locks after 5 minutes and outputs power off after 10; locking also happens before sleep.

## Repository layout

```
├── install.sh          # installer / deployer
├── current.jpg         # default wallpaper (deployed to ~/Pictures/Wallpapers/)
├── sway/
│   ├── config          # main SwayFX config
│   └── scripts/        # lock, menu, powermenu, screenshot
├── alacritty/          # terminal config
├── waybar/             # bar config + CSS
├── wofi/               # launcher config + CSS
├── mako/config         # notification daemon
└── awww/wallpaper.sh   # wallpaper script
```

## Contributing

Issues and pull requests are welcome — templates are provided. Shell scripts are checked with ShellCheck in CI; run `shellcheck install.sh sway/scripts/*.sh awww/wallpaper.sh` locally before opening a PR.

## License

[MIT](LICENSE)
