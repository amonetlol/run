#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT/lib/common.sh"

SRC_DIR="${SRC_DIR:-$HOME/.src}"
BACKUP_DIR="$HOME/.backup/system-$(date +%Y-%m-%d_%H-%M-%S)"
TARGET_DOTFILES="${TARGET_DOTFILES:-$HOME/.dotfiles}"
SOURCE_DOTFILES="$ROOT/dotfiles"

require_arch
require_not_root
require_git
ensure_sudo

install_yay_bin() {
    if command -v yay &>/dev/null; then
        ok "yay já instalado."
        return
    fi

    section "Instalando yay-bin"
    sudo pacman -S --needed --noconfirm git base-devel rsync curl
    mkdir -p "$SRC_DIR"
    clone_or_pull "https://aur.archlinux.org/yay-bin.git" "$SRC_DIR/yay-bin"
    (cd "$SRC_DIR/yay-bin" && makepkg -si --noconfirm --rmdeps)
}

install_packages() {
    section "Instalando pacotes"
    yay -S --needed --noconfirm --removemake \
        yay-bin \
        awww \
        starship zoxide \
        fzf eza bat fd \
        ripgrep fastfetch btop tmux \
        yazi cava bc stow brightnessctl \
        webp-pixbuf-loader gvfs \
        neovim lazygit cargo npm foot \
        sddm networkmanager network-manager-applet blueman \
        gcr gnome-keyring seahorse \
        open-vm-tools \
        hyprland hyprlock hypridle \
        hyprshot hyprcursor waybar swaync \
        swayosd cliphist rofi \
        waybar-module-pacman-updates-git \
        qt5ct qt5-wayland qt5-tools \
        qt5-quickcontrols2 layer-shell-qt5 \
        qt6ct qt6-wayland qt6-tools \
        layer-shell-qt kvantum-qt6-git \
        xdg-desktop-portal \
        xdg-desktop-portal-hyprland \
        xwayland-satellite \
        catppuccin-gtk-theme-mocha \
        papirus-icon-theme \
        papirus-folders-catppuccin-git \
        kvantum-theme-catppuccin-git \
        rose-pine-cursor \
        rose-pine-hyprcursor nwg-look \
        ttf-jetbrains-mono-nerd \
        otf-font-awesome \
        ttf-apple-emoji \
        thunar ark loupe papers \
        mpv celluloid mate-media \
        qt6-multimedia \
        qt6-multimedia-ffmpeg \
        gst-plugin-pipewire \
        gst-plugins-bad \
        gst-plugins-ugly tree
}

clean_user_configs() {
    section "Limpando configs antigas"
    rm -rf \
        "$HOME/Pictures/Avatars" \
        "$HOME/Pictures/Wallpapers" \
        "$HOME/Scripts" \
        "$HOME/.config/bat" \
        "$HOME/.config/btop" \
        "$HOME/.config/cava" \
        "$HOME/.config/fastfetch" \
        "$HOME/.config/foot" \
        "$HOME/.config/gtk-3.0" \
        "$HOME/.config/gtk-4.0" \
        "$HOME/.config/hypr" \
        "$HOME/.config/Kvantum" \
        "$HOME/.config/nvim" \
        "$HOME/.config/qt5ct" \
        "$HOME/.config/qt6ct" \
        "$HOME/.config/rofi" \
        "$HOME/.config/starship.toml" \
        "$HOME/.config/swaync" \
        "$HOME/.config/tmux" \
        "$HOME/.config/waybar" \
        "$HOME/.config/yazi" \
        "$HOME/.lesskey"
}

backup_system_configs() {
    mkdir -p "$BACKUP_DIR"
    [[ -f /boot/grub/grub.cfg ]] && sudo cp /boot/grub/grub.cfg "$BACKUP_DIR/"
    [[ -f /etc/default/grub ]] && sudo cp /etc/default/grub "$BACKUP_DIR/"
    [[ -f /etc/sddm.conf ]] && sudo cp /etc/sddm.conf "$BACKUP_DIR/"
    ok "Backup sistema: $BACKUP_DIR"
}

install_tmux_plugins() {
    section "Plugins Tmux"
    local tpm_dir="$HOME/.config/tmux/plugins/tpm"
    clone_or_pull "https://github.com/tmux-plugins/tpm" "$tpm_dir"
    TMUX_PLUGIN_MANAGER_PATH="$HOME/.config/tmux/plugins" \
        "$tpm_dir/bin/install_plugins"
}

apply_themes() {
    section "Temas GTK / ícones"
    papirus-folders -C cat-mocha-mauve --theme Papirus-Dark || true
    gsettings set org.gnome.desktop.interface gtk-theme 'catppuccin-mocha-mauve-standard+default' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface font-name 'JetBrainsMono Nerd Font 9' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
}

install_locale() {
    section "Locale pt_BR.UTF-8"
    if ! grep -q '^[[:space:]]*pt_BR.UTF-8[[:space:]]\+UTF-8' /etc/locale.gen; then
        sudo sed -i '/^[[:space:]]*#\s*pt_BR.UTF-8\s\+UTF-8/s/^#\s*//' /etc/locale.gen
    fi
    sudo locale-gen
}

install_sddm_theme() {
    section "Tema SDDM"
    local sddm_script="$HOME/.dotfiles/scripts/Scripts/sddm.sh"
    [[ -x "$sddm_script" ]] || return 0
    "$sddm_script" install
    "$sddm_script" welcome-to-the-metro
}

install_grub_theme() {
    local grub_theme_dir="$HOME/.dotfiles/grub/themes/CyberEXS"
    local grub_theme_config="/boot/grub/themes/CyberEXS/theme.txt"
    [[ -d /boot/grub && -f "$grub_theme_dir/theme.txt" ]] || return 0
    section "Tema GRUB"
    sudo mkdir -p /boot/grub/themes
    sudo cp -ru "$grub_theme_dir" /boot/grub/themes/
    if grep -q '^GRUB_THEME=' /etc/default/grub; then
        sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=$grub_theme_config|" /etc/default/grub
    else
        echo "GRUB_THEME=$grub_theme_config" | sudo tee -a /etc/default/grub >/dev/null
    fi
    sudo grub-mkconfig -o /boot/grub/grub.cfg
}

set_default_apps() {
    section "Apps padrão (Firefox)"
    command -v xdg-mime &>/dev/null || return 0
    xdg-mime default firefox.desktop x-scheme-handler/http 2>/dev/null || true
    xdg-mime default firefox.desktop x-scheme-handler/https 2>/dev/null || true
    xdg-mime default firefox.desktop text/html 2>/dev/null || true
}

enable_services() {
    section "Serviços systemd"
    sudo systemctl enable NetworkManager sddm vmtoolsd swayosd-libinput-backend.service
    sudo systemctl start vmtoolsd 2>/dev/null || true
    systemctl --user enable xwayland-satellite.service 2>/dev/null || true
}

prepare_dirs() {
    mkdir -p "$HOME/.cache/awww" "$SRC_DIR" "$HOME/Pictures/Wallpapers"
}

verify_dotfiles() {
    if [[ ! -d "$SOURCE_DOTFILES" || -z "$(ls -A "$SOURCE_DOTFILES" 2>/dev/null)" ]]; then
        fail "dotfiles/ não encontrado ou vazio. Coloque seu dotfiles definitivo em $SOURCE_DOTFILES e execute novamente."
    fi
}

main() {
    section "INSTALL_FINAL — dot-catppuccin"
    verify_dotfiles

    require_arch
    require_not_root
    ensure_sudo

    sudo pacman -Syyu --noconfirm
    install_yay_bin
    install_packages
    prepare_dirs
    backup_system_configs
    clean_user_configs

    section "Aplicando dotfiles definitivos"
    "$ROOT/stow.sh"

    set_default_apps
    install_tmux_plugins
    apply_themes
    install_locale
    install_sddm_theme
    install_grub_theme
    enable_services

    section "INSTALAÇÃO FINAL CONCLUÍDA"
    ok "Reinicie para entrar via SDDM + Hyprland."
    read -rp "Reiniciar agora? [s/n]: " ans
    [[ "$ans" =~ ^[sSyY]$ ]] && sudo reboot
}

main "$@"
