#!/usr/bin/env bash
# install.sh — installs packages and deploys the configs in this repo to ~/.config.
#
# Usage:
#   ./install.sh            # install packages + copy configs (backs up existing ones)
#   ./install.sh --symlink  # symlink configs into ~/.config instead of copying
#   ./install.sh --no-pkgs  # skip package installation, only deploy configs
#   ./install.sh --dry-run  # print what would happen, change nothing
#
# Safe to re-run: existing ~/.config dirs are backed up (never silently overwritten),
# already-installed packages are skipped, and nothing destructive runs without you
# confirming the pacman/AUR prompts yourself.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

SYMLINK=0
INSTALL_PKGS=1
DRY_RUN=0

for arg in "$@"; do
    case "$arg" in
        --symlink) SYMLINK=1 ;;
        --no-pkgs) INSTALL_PKGS=0 ;;
        --dry-run) DRY_RUN=1 ;;
        *) echo "unknown flag: $arg" >&2; exit 1 ;;
    esac
done

log()  { printf '\033[1;34m::\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m::\033[0m %s\n' "$1" >&2; }
run()  { if [ "$DRY_RUN" = 1 ]; then echo "+ $*"; else "$@"; fi; }

if [ "$EUID" -eq 0 ]; then
    echo "Don't run this as root — it uses sudo itself where needed." >&2
    exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
    echo "pacman not found — this installer targets Arch/CachyOS." >&2
    exit 1
fi

# ─────────────────────────────────────────────
# 1. Packages
# ─────────────────────────────────────────────
ALL_PKGS=(
    waybar wofi foot wl-clipboard
    xdg-desktop-portal-wlr xdg-desktop-portal xorg-xwayland
    grim slurp swaylock-effects swayidle brightnessctl playerctl
    pipewire pipewire-pulse wireplumber
    polkit-gnome ttf-jetbrains-mono-nerd jq
    mako swayfx awww
)

if [ "$INSTALL_PKGS" = 1 ]; then
    log "Syncing package databases..."
    run sudo pacman -Sy

    log "Checking which packages are already installed..."
    to_install=()
    for pkg in "${ALL_PKGS[@]}"; do
        pacman -Qi "$pkg" >/dev/null 2>&1 || to_install+=("$pkg")
    done

    if [ ${#to_install[@]} -eq 0 ]; then
        log "All packages already installed."
    else
        repo_pkgs=()
        aur_pkgs=()
        for pkg in "${to_install[@]}"; do
            if pacman -Si "$pkg" >/dev/null 2>&1; then
                repo_pkgs+=("$pkg")
            else
                aur_pkgs+=("$pkg")
            fi
        done

        if [ ${#repo_pkgs[@]} -gt 0 ]; then
            log "Installing from official repos: ${repo_pkgs[*]}"
            run sudo pacman -S --needed "${repo_pkgs[@]}"
        fi

        if [ ${#aur_pkgs[@]} -gt 0 ]; then
            aur_helper=""
            if command -v yay >/dev/null 2>&1; then
                aur_helper="yay"
            elif command -v paru >/dev/null 2>&1; then
                aur_helper="paru"
            fi

            if [ -n "$aur_helper" ]; then
                log "Installing from AUR via $aur_helper: ${aur_pkgs[*]}"
                run "$aur_helper" -S --needed "${aur_pkgs[@]}"
            else
                warn "No AUR helper (yay/paru) found — skipping: ${aur_pkgs[*]}"
                warn "Install one first, e.g.:"
                warn "  git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si"
                warn "then re-run: ./install.sh --no-pkgs=0"
            fi
        fi
    fi
else
    log "Skipping package installation (--no-pkgs)."
fi

# ─────────────────────────────────────────────
# 2. Deploy configs (backup anything already there)
# ─────────────────────────────────────────────
DIRS=(sway waybar mako awww wofi)
backed_up=0

for d in "${DIRS[@]}"; do
    src="$SCRIPT_DIR/$d"
    dst="$CONFIG_DIR/$d"

    if [ -e "$dst" ] || [ -L "$dst" ]; then
        if [ "$backed_up" = 0 ]; then
            run mkdir -p "$BACKUP_DIR"
            backed_up=1
        fi
        log "Backing up existing $dst -> $BACKUP_DIR/$d"
        run mv "$dst" "$BACKUP_DIR/$d"
    fi

    if [ "$SYMLINK" = 1 ]; then
        log "Symlinking $dst -> $src"
        run ln -s "$src" "$dst"
    else
        log "Copying $src -> $dst"
        run cp -r "$src" "$dst"
    fi
done

run chmod +x "$CONFIG_DIR/sway/scripts/lock.sh" \
             "$CONFIG_DIR/sway/scripts/powermenu.sh" \
             "$CONFIG_DIR/sway/scripts/screenshot.sh" \
             "$CONFIG_DIR/awww/wallpaper.sh"

# ─────────────────────────────────────────────
# 3. Wallpaper + screenshot directories
# ─────────────────────────────────────────────
run mkdir -p "$HOME/Pictures/Wallpapers" "$HOME/Pictures/Screenshots"

WALLPAPER="$HOME/Pictures/Wallpapers/current.jpg"
if [ ! -e "$WALLPAPER" ]; then
    if command -v magick >/dev/null 2>&1; then
        log "No wallpaper found — generating a plain dark placeholder at $WALLPAPER"
        run magick -size 1920x1080 xc:'#1a1b26' "$WALLPAPER"
    else
        warn "No wallpaper found at $WALLPAPER — drop an image there before starting sway."
    fi
fi

# ─────────────────────────────────────────────
# 4. Audio services (usually already enabled on Arch, harmless if so)
# ─────────────────────────────────────────────
if command -v systemctl >/dev/null 2>&1; then
    run systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true
fi

log "Done."
[ "$backed_up" = 1 ] && log "Previous configs backed up to $BACKUP_DIR"
log "Next steps:"
log "  1. Confirm '${WALLPAPER}' is the image you want."
log "  2. Check your output name: swaymsg -t get_outputs (edit 'output *' in sway/config if needed)."
log "  3. Log into a Sway session (or run 'sway' from a TTY)."
