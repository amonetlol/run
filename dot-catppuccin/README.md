# dot-catppuccin

Dotfiles HyprPunk personalizados (Catppuccin Mocha, BR-ABNT2, VMware).

## Estrutura

```
dot-catppuccin/
├── dotfiles/          # Módulos GNU Stow (gerados por build-dotfiles.sh), incluindo bash
├── overrides/         # Patches sobre HyprPunk (versionados no git)
├── build-dotfiles.sh  # Clona HyprPunk + aplica overrides + bash amonetlol
├── stow.sh            # Instala em ~/.dotfiles e aplica stow no $HOME
├── install.sh         # Pacotes Arch + build + stow + temas + serviços
└── lib/common.sh
```

## Instalação rápida (Arch minimal)

```bash
git clone https://github.com/SEU_USUARIO/dot-catppuccin.git ~/.src/dot-catppuccin
cd ~/.src/dot-catppuccin
sed -i 's/\r$//' *.sh lib/*.sh   # se veio do Windows
chmod +x *.sh
./install.sh
```

## Só dotfiles (sem pacotes)

```bash
./build-dotfiles.sh   # gera dotfiles/
./stow.sh             # aplica em ~/.dotfiles + $HOME
```

## Customizações principais

| Item | Valor |
|------|--------|
| Terminal | Foot (`Super+Return`) |
| Arquivos | Thunar (`Super+E`) |
| Browser | Firefox (`Super+W`) |
| Launcher | Rofi (`Super+D`) |
| Powermenu | `Super+X` |
| Cliphist | `Super+V` |
| Wallpaper | `Super+F10` (awww) |
| Float | `Super+P` |
| Fullscreen | `Super+F` |
| Waybar reload | `Super+F12` |
| Teclado | br-abnt2 |
| Wallpaper daemon | awww (não hyprpaper) |
| Shell | bash + starship (amonetlol/dot) |
| Monitor VM | `ACTIVE_MODE = "vm"` em monitors.lua |

## GitHub

1. Rode `./build-dotfiles.sh` na VM Arch
2. Rode `./stow.sh` para validar os links simbólicos
3. Commit `dotfiles/`, `overrides/`, `build-dotfiles.sh`, `stow.sh`, `install.sh` e `README.md`
4. `.gitignore` já exclui caches locais

## Créditos

- [HyprPunk](https://github.com/tuconnaisyouknow/HyprPunk)
- [amonetlol/dot](https://github.com/amonetlol/dot) (bash)
