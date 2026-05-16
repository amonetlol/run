{ config, pkgs, ... }:

{

  # Habilitar Hyprland e SDDM
  programs.hyprland.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Correções para renderização em VM
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
  };

# Configuração de Fontes do Sistema
fonts.packages = with pkgs; [
  nerd-fonts.jetbrains-mono
];

  # 1. Utilizar o último Kernel disponível
  #boot.kernelPackages = pkgs.linuxPackages_latest;

  # 2. Ativar o Foot como terminal padrão do sistema
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=11";
      };
    };
  };

  # 3. Ativar o Thunar com os plugins solicitados
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  
  # Serviços necessários para o Thunar (Lixeira, montagem de discos e extração)
  services.gvfs.enable = true; # Essencial para lixeira e redes no Thunar
  services.tumbler.enable = true; # Miniaturas de imagens
  #programs.file-roller.enable = true; # Backend para o thunar-archive-plugin (substitui bem o xarchiver)

  # 4. Programas com módulos dedicados (melhor integração de shell)
  programs.starship.enable = true;
  programs.zoxide.enable = true;
  #programs.fzf.enable = true;
  programs.git.enable = true;
  programs.firefox.enable = true;

  # 5. Restante dos pacotes convertidos para o NixOS
  environment.systemPackages = with pkgs; [
    # Utilitários de Terminal Modernos
    eza
    fd
    ripgrep
    duf
    fastfetch
    btop
    htop
    lazygit
    wget
    curl
    bc
    starship
    
    # Editores e Visualizadores
    neovim
    xarchiver # Caso ainda prefira ele ao invés do file-roller
    
    # Desenvolvimento & Compiladores
    gcc
    luarocks
    lua51Packages.lua
    tree-sitter
    jq
    nodePackages.npm
    nodejs
    (python3.withPackages (ps: with ps; [
      pipenv
      pynvim
    ])) # Forma correta de instalar pacotes python globais no NixOS

    # Ferramentas Base (O NixOS já inclui a maioria, mas garante que estejam aqui)
    findutils
    coreutils
    bash-completion

   # Hyprland
    rofi
    waybar
    wl-clipboard
  ];

  # Não se esqueça de manter suas configurações anteriores do VMware e Hyprland aqui!
}
