#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT/lib/common.sh"

require_arch
require_not_root

TARGET_DOTFILES="${TARGET_DOTFILES:-$HOME/.dotfiles}"
SOURCE_DOTFILES="$ROOT/dotfiles"

section "STOW — dot-catppuccin"

if [[ ! -d "$SOURCE_DOTFILES" || -z "$(ls -A "$SOURCE_DOTFILES" 2>/dev/null)" ]]; then
	warn "dotfiles/ vazio — executando build-dotfiles.sh..."
	"$ROOT/build-dotfiles.sh"
fi

install_packages_smart stow

# Copiar/sincronizar para ~/.dotfiles
if [[ "$SOURCE_DOTFILES" != "$TARGET_DOTFILES" ]]; then
	if [[ -e "$TARGET_DOTFILES" && ! -L "$TARGET_DOTFILES" ]]; then
		backup_path "$TARGET_DOTFILES"
	fi
	log "Sincronizando: $SOURCE_DOTFILES -> $TARGET_DOTFILES"
	mkdir -p "$TARGET_DOTFILES"
	rsync -a --delete "$SOURCE_DOTFILES/" "$TARGET_DOTFILES/"
fi

ask_pc_type() {
	while true; do
		read -rp "Notebook ou desktop? [l/d]: " pc_input
		case "$pc_input" in
			l | L) pc_type="laptop"; break ;;
			d | D) pc_type="desktop"; break ;;
			*) echo "Digite 'l' ou 'd'." ;;
		esac
	done
}

ask_pc_type

packages=(
	bash
	foot
	starship
	fastfetch
	bat btop cava gtk3 gtk4 hypridle hyprland
	kvantum less nvim qt5 qt6 rofi scripts swaync tmux wallpapers yazi
	avatars
)

if [[ "$pc_type" == "laptop" ]]; then
	packages+=(waybar hyprlock)
else
	packages+=(waybar-desktop hyprlock-desktop)
fi

# Remover módulos que não existem
filtered=()
for pkg in "${packages[@]}"; do
	[[ -d "$TARGET_DOTFILES/$pkg" ]] && filtered+=("$pkg")
done

section "Resolvendo conflitos comuns"

backup_if_real_file() {
	local target="$1"
	if [[ -e "$target" && ! -L "$target" ]]; then
		local backup="${target}.bak-$(date +%Y%m%d-%H%M%S)"
		warn "Conflito: $target -> $backup"
		mv "$target" "$backup"
	fi
}

for f in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile" \
	"$HOME/.aliases" "$HOME/.aliases-arch" "$HOME/.functions"; do
	backup_if_real_file "$f"
done

section "Aplicando GNU Stow"

cd "$TARGET_DOTFILES"
for pkg in "${filtered[@]}"; do
	log "stow: $pkg"
	stow -v -t "$HOME" --restow "$pkg"
done

section "Permissões"

chmod +x "$HOME/Scripts/Rofi/"*.sh 2>/dev/null || true
find "$HOME/Scripts" -type f -name '*.sh' -exec chmod +x {} \; 2>/dev/null || true

if [[ -d "$HOME/.config/waybar/scripts" ]]; then
	find "$HOME/.config/waybar/scripts" -type f -exec chmod +x {} \;
fi

mkdir -p "$HOME/.cache/awww"

section "STOW CONCLUÍDO"
ok "Dotfiles aplicados em \$HOME via $TARGET_DOTFILES"

cat <<EOF

Atalhos principais:
  Super+Return  Foot
  Super+E       Thunar
  Super+W       Firefox
  Super+D       Rofi
  Super+X       Powermenu
  Super+V       Cliphist
  Super+F10     Wallpaper
  Super+P       Toggle float
  Super+F       Fullscreen
  Super+F12     Reload Waybar

EOF
