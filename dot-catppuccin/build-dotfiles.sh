#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT/lib/common.sh"

HYPRPUNK_REPO="${HYPRPUNK_REPO:-https://github.com/tuconnaisyouknow/HyprPunk.git}"
AMONET_BASH_REPO="${AMONET_BASH_REPO:-https://github.com/amonetlol/dot.git}"
SRC_DIR="${SRC_DIR:-$HOME/.src}"
BUILD_DIR="$SRC_DIR/hyprpunk-build-$$"
DOTFILES_DIR="$ROOT/dotfiles"
OVERRIDES_DIR="$ROOT/overrides"

require_git

section "BUILD DOTFILES — HyprPunk + overrides dot-catppuccin"

LOCAL_BASH_BACKUP="$SRC_DIR/dotfiles-bash-backup"
if [[ -d "$DOTFILES_DIR/bash" ]]; then
    rm -rf "$LOCAL_BASH_BACKUP"
    mkdir -p "$LOCAL_BASH_BACKUP"
    cp -a "$DOTFILES_DIR/bash" "$LOCAL_BASH_BACKUP/"
fi

rm -rf "$DOTFILES_DIR"
mkdir -p "$DOTFILES_DIR"

log "Clonando HyprPunk..."
git clone --depth 1 "$HYPRPUNK_REPO" "$BUILD_DIR"

# Módulos Stow (sem kitty, zsh, hyprpaper; adiciona bash local)
STOW_MODULES=(
	bash avatars bat btop cava fastfetch gtk3 gtk4 hypridle hyprland
	hyprlock hyprlock-desktop nvim qt5 qt6 rofi scripts
	starship swaync tmux wallpapers waybar waybar-desktop yazi
)

for mod in "${STOW_MODULES[@]}"; do
	if [[ -d "$BUILD_DIR/$mod" ]]; then
		cp -a "$BUILD_DIR/$mod" "$DOTFILES_DIR/"
	fi
done

# foot (override local)
rm -rf "$DOTFILES_DIR/hyprpaper"
mkdir -p "$DOTFILES_DIR/foot/.config/foot"

# Bash (amonetlol/dot) ou local
if [[ -d "$LOCAL_BASH_BACKUP/bash" ]]; then
    log "Restaurando bash local do dotfiles/bash..."
    mkdir -p "$DOTFILES_DIR/bash"
    cp -a "$LOCAL_BASH_BACKUP/bash/." "$DOTFILES_DIR/bash/"
else
    log "Baixando bash dotfiles de amonetlol/dot..."
    mkdir -p "$DOTFILES_DIR/bash"
    for f in .bashrc .aliases .aliases-arch .functions; do
        curl -fsSL "$AMONET_BASH_REPO/raw/main/dotfiles/bash/$f" \
            -o "$DOTFILES_DIR/bash/$f"
    done
fi

section "Aplicando overrides"

apply_overrides() {
	local src="$OVERRIDES_DIR"
	local dst="$DOTFILES_DIR"

	while IFS= read -r -d '' file; do
		rel="${file#$src/}"
		target="$dst/$rel"
		mkdir -p "$(dirname "$target")"
		cp -f "$file" "$target"
		log "override: $rel"
	done < <(find "$src" -type f -print0)
}

apply_overrides

section "Patches HyprPunk (hyprland.lua)"

HYPR_LUA="$DOTFILES_DIR/hyprland/.config/hypr/hyprland.lua"
if [[ -f "$HYPR_LUA" ]]; then
	sed -i \
		-e 's/hl.exec_cmd("hyprpaper")/hl.exec_cmd("awww-daemon")/' \
		-e 's/class = "brave-browser"/class = "firefox"/' \
		-e 's/kb_layout = "fr"/kb_layout = "br"/' \
		-e 's/kb_variant = ""/kb_variant = "abnt2"/' \
		"$HYPR_LUA"
	ok "hyprland.lua patcheado (awww, firefox, br-abnt2)"
fi

# Permissões em scripts Rofi
find "$DOTFILES_DIR/scripts" -type f -name '*.sh' -exec chmod +x {} \; 2>/dev/null || true

rm -rf "$LOCAL_BASH_BACKUP"
rm -rf "$BUILD_DIR"

section "BUILD CONCLUÍDO"
ok "Dotfiles prontos em: $DOTFILES_DIR"
echo ""
echo "Próximo passo: ./stow.sh"
