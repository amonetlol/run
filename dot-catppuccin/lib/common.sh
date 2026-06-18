#!/usr/bin/env bash
# shellcheck disable=SC1091

log() { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
ok() { printf '\033[1;32m[ok]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31m[fail]\033[0m %s\n' "$*" >&2; exit 1; }

section() {
	echo ""
	printf '\033[1;35m=== %s ===\033[0m\n' "$*"
}

require_arch() {
	command -v pacman &>/dev/null || fail "Apenas Arch Linux."
}

require_not_root() {
	[[ "${EUID:-$(id -u)}" -eq 0 ]] && fail "Não execute como root."
}

require_git() {
	command -v git &>/dev/null || fail "git não encontrado."
}

ensure_sudo() {
	command -v sudo &>/dev/null || fail "sudo não encontrado."
}

backup_path() {
	local path="$1"
	[[ -e "$path" ]] || return 0
	local bak="${path}.bak-$(date +%Y%m%d-%H%M%S)"
	mv "$path" "$bak"
	warn "Backup: $bak"
}

install_packages_smart() {
	local pkgs=("$@")
	if command -v yay &>/dev/null; then
		yay -S --needed --noconfirm "${pkgs[@]}"
	elif command -v pacman &>/dev/null; then
		sudo pacman -S --needed --noconfirm "${pkgs[@]}"
	else
		fail "Nenhum gerenciador de pacotes encontrado."
	fi
}

clone_or_pull() {
	local repo="$1"
	local dir="$2"
	if [[ -d "$dir/.git" ]]; then
		git -C "$dir" pull --ff-only
	else
		git clone "$repo" "$dir"
	fi
}
