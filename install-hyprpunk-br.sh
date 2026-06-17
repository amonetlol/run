#!/usr/bin/env bash
#
# Instalador HyprPunk personalizado para Arch Linux (BR / ABNT2)
# Base: https://github.com/tuconnaisyouknow/HyprPunk
#
# Alterações em relação ao instalador original:
#   - yay-bin (AUR pré-compilado)
#   - open-vm-tools + vmtoolsd
#   - SDDM habilitado
#   - terminal: foot          (Super + Return)
#   - file manager: thunar    (Super + E)
#   - browser: firefox        (Super + W)
#   - launcher: rofi          (Super + D)
#   - powermenu               (Super + X)
#   - teclado: br-abnt2
#
# Uso (como usuário normal, com sudo disponível):
#   bash install-hyprpunk-br.sh
#

set -euo pipefail

DOTFILES_REPO="https://github.com/tuconnaisyouknow/HyprPunk.git"
DOTFILES_DIR="$HOME/.dotfiles"
SRC_DIR="$HOME/.src"
BACKUP_DIR="$HOME/.backup/system-$(date +%Y-%m-%d_%H-%M-%S)"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

log() { printf '\033[1;36m==>\033[0m %s\n' "$*"; }

clone_or_pull() {
    local repo="$1"
    local dir="$2"

    if [[ -d "$dir/.git" ]]; then
        git -C "$dir" pull
    else
        git clone "$repo" "$dir"
    fi
}

require_arch() {
    if ! command -v pacman &>/dev/null; then
        echo "Este script foi feito apenas para Arch Linux."
        exit 1
    fi
}

ask_pc_type() {
    while true; do
        read -rp "Notebook ou desktop? [l/d]: " pc_input
        case "$pc_input" in
            l | L) pc_type="laptop"; break ;;
            d | D) pc_type="desktop"; break ;;
            *) echo "Digite 'l' (notebook) ou 'd' (desktop)." ;;
        esac
    done
}

# ---------------------------------------------------------------------------
# Pacotes e AUR
# ---------------------------------------------------------------------------

install_yay_bin() {
    if command -v yay &>/dev/null; then
        log "yay já instalado."
        return
    fi

    log "Instalando yay-bin do AUR..."
    sudo pacman -S --needed --noconfirm git base-devel

    mkdir -p "$SRC_DIR"
    clone_or_pull "https://aur.archlinux.org/yay-bin.git" "$SRC_DIR/yay-bin"
    (cd "$SRC_DIR/yay-bin" && makepkg -si --noconfirm --rmdeps)
}

update_system() {
    log "Atualizando o sistema..."
    sudo pacman -Syyu --noconfirm
}

install_packages() {
    log "Instalando pacotes (oficiais + AUR)..."
    yay -S --needed --noconfirm --removemake \
        yay-bin \
        starship zoxide \
        fzf eza bat fd \
        ripgrep fastfetch btop tmux \
        yazi cava bc stow brightnessctl \
        webp-pixbuf-loader gvfs \
        neovim lazygit cargo npm \
        \
        sddm networkmanager network-manager-applet blueman \
        gcr gnome-keyring seahorse \
        open-vm-tools \
        \
        hyprland hyprpaper hyprlock hypridle \
        hyprshot hyprcursor waybar swaync \
        swayosd cliphist rofi \
        waybar-module-pacman-updates-git \
        \
        qt5ct qt5-wayland qt5-tools \
        qt5-quickcontrols2 layer-shell-qt5 \
        qt6ct qt6-wayland qt6-tools \
        layer-shell-qt kvantum-qt6-git \
        \
        xdg-desktop-portal \
        xdg-desktop-portal-hyprland \
        xwayland-satellite \
        \
        catppuccin-gtk-theme-mocha \
        papirus-icon-theme \
        papirus-folders-catppuccin-git \
        kvantum-theme-catppuccin-git \
        rose-pine-cursor \
        rose-pine-hyprcursor nwg-look \
        \
        ttf-jetbrains-mono-nerd \
        otf-font-awesome \
        ttf-apple-emoji \
        \
        foot firefox thunar ark loupe papers \
        mpv celluloid mate-media \
        \
        qt6-multimedia \
        qt6-multimedia-ffmpeg \
        gst-plugin-pipewire \
        gst-plugins-bad \
        gst-plugins-ugly
}

# ---------------------------------------------------------------------------
# Dotfiles
# ---------------------------------------------------------------------------

clean_user_configs() {
    log "Removendo configs antigas do usuário..."
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
        "$HOME/.config/hypr/hypridle.conf" \
        "$HOME/.config/hypr/hyprland.conf" \
        "$HOME/.config/hypr/hyprlock.conf" \
        "$HOME/.config/hypr/hyprpaper.conf" \
        "$HOME/.config/kitty" \
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

    log "Backup de configs do sistema em: $BACKUP_DIR"
}

install_dotfiles() {
    log "Clonando HyprPunk e aplicando com GNU Stow..."
    rm -rf "$DOTFILES_DIR"
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"

    # kitty não é usado (foot); demais módulos iguais ao original
    if [[ "$pc_type" == "laptop" ]]; then
        stow --dir "$DOTFILES_DIR" --target "$HOME" \
            avatars bat btop cava fastfetch gtk3 gtk4 hypridle hyprland \
            hyprlock hyprpaper kvantum less nvim qt5 qt6 rofi scripts \
            starship swaync tmux wallpapers waybar yazi
    else
        stow --dir "$DOTFILES_DIR" --target "$HOME" \
            avatars bat btop cava fastfetch gtk3 gtk4 hypridle hyprland \
            hyprlock-desktop hyprpaper kvantum less nvim qt5 qt6 rofi scripts \
            starship swaync tmux wallpapers waybar-desktop yazi
    fi
}

# ---------------------------------------------------------------------------
# Personalizações BR
# ---------------------------------------------------------------------------

install_foot_config() {
    log "Configurando Foot (terminal)..."
    mkdir -p "$HOME/.config/foot"

    cat >"$HOME/.config/foot/foot.ini" <<'EOF'
# Foot — tema escuro compatível com HyprPunk / Catppuccin Mocha
font=JetBrainsMono Nerd Font:size=11
pad=8x8

[colors]
foreground=cdd6f4
background=1e1e2e
regular0=45475a
regular1=f38ba8
regular2=a6e3a1
regular3=f9e2af
regular4=89b4fa
regular5=cba6f7
regular6=94e2d5
regular7=bac2de
bright0=585b70
bright1=f38ba8
bright2=a6e3a1
bright3=f9e2af
bright4=89b4fa
bright5=cba6f7
bright6=94e2d5
bright7=a6adc8
EOF
}

apply_customizations() {
    log "Aplicando atalhos, apps e layout de teclado BR-ABNT2..."

    local keybindings="$HOME/.config/hypr/keybindings.lua"
    local hyprland_cfg="$HOME/.config/hypr/hyprland.lua"

    # Apps
    sed -i \
        -e 's/local terminal = "kitty"/local terminal = "foot"/' \
        -e 's/local browser = "brave"/local browser = "firefox"/' \
        "$keybindings"

    # Super + Return → terminal
    sed -i \
        -e 's/bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal)/bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal)/' \
        "$keybindings"

    # Super + W → browser (original: Super + B)
    sed -i \
        -e 's/bind(mainMod .. " + B", hl.dsp.exec_cmd(browser)/bind(mainMod .. " + W", hl.dsp.exec_cmd(browser)/' \
        "$keybindings"

    # Super + D → rofi launcher (original: discord)
    sed -i \
        -e 's/hl.dsp.exec_cmd("discord")/hl.dsp.exec_cmd('\''rofi -show drun -show-icons -display-drun " Apps "'\'')/' \
        -e 's/open discord/open app launcher/' \
        "$keybindings"

    # Super + X → powermenu
    if ! grep -q 'mainMod .. " + X"' "$keybindings"; then
        cat >>"$keybindings" <<'LUA'

bind(mainMod .. " + X", hl.dsp.exec_cmd("~/Scripts/Rofi/system.sh standalone"), "[" .. launcher .. "|rofi menus] power menu")
LUA
    fi

    # Teclado BR-ABNT2
    sed -i \
        -e 's/kb_layout = "fr"/kb_layout = "br"/' \
        -e 's/kb_variant = ""/kb_variant = "abnt2"/' \
        "$hyprland_cfg"

    # Regra de janela: Firefox em vez de Brave
    sed -i \
        -e 's/class = "brave-browser"/class = "firefox"/' \
        "$hyprland_cfg"

    install_foot_config
}

set_default_apps() {
    log "Definindo aplicativos padrão..."

    local loupe="org.gnome.Loupe.desktop"
    local papers="org.gnome.Papers.desktop"
    local mpv="mpv.desktop"
    local celluloid="io.github.celluloid_player.Celluloid.desktop"
    local firefox="firefox.desktop"

    set_default() {
        local desktop_file="$1"
        shift

        if [[ ! -f "/usr/share/applications/$desktop_file" && ! -f "$HOME/.local/share/applications/$desktop_file" ]]; then
            echo "Aviso: $desktop_file não encontrado, pulando."
            return
        fi

        for mime in "$@"; do
            xdg-mime default "$desktop_file" "$mime"
        done
    }

    set_default "$firefox" \
        text/html \
        x-scheme-handler/http \
        x-scheme-handler/https \
        application/xhtml+xml

    set_default "$loupe" \
        image/avif image/bmp image/x-dds image/gif image/heif image/vnd.microsoft.icon \
        image/jpeg image/jxl image/x-exr image/png image/x-portable-anymap \
        image/x-portable-bitmap image/x-portable-graymap image/x-portable-pixmap \
        image/qoi image/svg+xml image/x-tga image/tiff image/webp

    set_default "$papers" application/pdf

    set_default "$mpv" \
        video/mp4 video/x-msvideo video/x-matroska video/webm video/ogg \
        video/quicktime video/mpeg video/x-ms-wmv video/x-flv video/3gpp \
        video/3gpp2 video/mp2t video/x-ogm+ogg video/x-theora+ogg \
        video/x-ms-asf video/x-m4v video/x-f4v video/x-fli video/x-mng \
        video/x-nsv video/vnd.rn-realvideo

    set_default "$celluloid" \
        audio/mpeg audio/mp4 audio/aac audio/x-aac audio/flac audio/x-flac \
        audio/ogg audio/opus audio/vorbis audio/webm audio/wav audio/x-wav \
        audio/x-aiff audio/aiff audio/basic audio/midi audio/x-midi \
        audio/x-ms-wma audio/x-m4a audio/x-mpegurl audio/vnd.rn-realaudio
}

install_tmux_plugins() {
    log "Instalando plugins do Tmux..."
    local tpm_dir="$HOME/.config/tmux/plugins/tpm"

    clone_or_pull "https://github.com/tmux-plugins/tpm" "$tpm_dir"

    TMUX_PLUGIN_MANAGER_PATH="$HOME/.config/tmux/plugins" \
        "$tpm_dir/bin/install_plugins"
}

apply_themes() {
    log "Aplicando temas GTK / ícones..."
    papirus-folders -C cat-mocha-mauve --theme Papirus-Dark || true

    gsettings set org.gnome.desktop.interface gtk-theme 'catppuccin-mocha-mauve-standard+default'
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
    gsettings set org.gnome.desktop.interface font-name 'JetBrainsMono Nerd Font 9'
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
}

install_locale() {
    log "Configurando locale pt_BR.UTF-8..."
    if ! grep -q '^[[:space:]]*pt_BR.UTF-8[[:space:]]\+UTF-8' /etc/locale.gen; then
        sudo sed -i '/^[[:space:]]*#\s*pt_BR.UTF-8\s\+UTF-8/s/^#\s*//' /etc/locale.gen
    fi
    sudo locale-gen
}

install_sddm_theme() {
    log "Instalando tema SDDM..."
    local sddm_script="$DOTFILES_DIR/scripts/Scripts/sddm.sh"

    "$sddm_script" install
    "$sddm_script" welcome-to-the-metro
}

install_grub_theme() {
    local grub_theme_dir="$DOTFILES_DIR/grub/themes/CyberEXS"
    local grub_theme_target="/boot/grub/themes/CyberEXS"
    local grub_theme_config="$grub_theme_target/theme.txt"

    if [[ ! -d /boot/grub ]]; then
        echo "GRUB não encontrado, pulando tema GRUB."
        return
    fi

    if [[ ! -f "$grub_theme_dir/theme.txt" ]]; then
        echo "Tema GRUB não encontrado: $grub_theme_dir/theme.txt"
        return
    fi

    log "Instalando tema GRUB CyberEXS..."
    sudo mkdir -p /boot/grub/themes
    sudo cp -ru "$grub_theme_dir" /boot/grub/themes/

    if grep -q '^#GRUB_THEME=' /etc/default/grub; then
        sudo sed -i "s|^#GRUB_THEME=.*|GRUB_THEME=$grub_theme_config|" /etc/default/grub
    elif grep -q '^GRUB_THEME=' /etc/default/grub; then
        sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=$grub_theme_config|" /etc/default/grub
    else
        echo "GRUB_THEME=$grub_theme_config" | sudo tee -a /etc/default/grub >/dev/null
    fi

    sudo grub-mkconfig -o /boot/grub/grub.cfg
}

enable_services() {
    log "Habilitando serviços do sistema..."
    sudo systemctl enable NetworkManager
    sudo systemctl enable sddm
    sudo systemctl enable vmtoolsd
    sudo systemctl enable swayosd-libinput-backend.service

    sudo systemctl start vmtoolsd || true

    systemctl --user enable xwayland-satellite.service || true
}

ask_reboot() {
    read -rp "Reiniciar agora? [s/n]: " answer

    case "$answer" in
        s | S | y | Y) sudo reboot ;;
        *) echo "Instalação concluída. Reinicie manualmente para usar o SDDM + Hyprland." ;;
    esac
}

print_summary() {
    cat <<'EOF'

╔══════════════════════════════════════════════════════════════╗
║  HyprPunk BR — instalação concluída                          ║
╠══════════════════════════════════════════════════════════════╣
║  Super + Return  → Foot (terminal)                            ║
║  Super + E       → Thunar (arquivos)                          ║
║  Super + W       → Firefox                                    ║
║  Super + D       → Rofi (launcher)                            ║
║  Super + X       → Powermenu (lock/logout/reboot/shutdown)    ║
║  Teclado         → br-abnt2                                   ║
║  Display manager → SDDM                                       ║
║  VM              → open-vm-tools (vmtoolsd)                   ║
╚══════════════════════════════════════════════════════════════╝

EOF
}

main() {
    require_arch
    update_system
    ask_pc_type

    mkdir -p "$SRC_DIR"

    install_yay_bin
    install_packages
    backup_system_configs
    clean_user_configs
    install_dotfiles
    apply_customizations
    set_default_apps
    install_tmux_plugins
    apply_themes
    install_locale
    install_sddm_theme
    install_grub_theme
    enable_services
    print_summary
    ask_reboot
}

main "$@"
