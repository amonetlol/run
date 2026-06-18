# dot-catppuccin — Instalação Definitiva

Repositório de dotfiles HyprPunk personalizados com Catppuccin Mocha, BR-ABNT2 e VM suporte.

## Estrutura principal

```
dot-catppuccin/
├── dotfiles/            # Dotfiles definitivos prontos para GNU Stow
├── overrides/           # Patches usados durante o build inicial
├── build-dotfiles.sh    # Gera dotfiles/ a partir do HyprPunk + overrides
├── install.sh           # Instala completa (usa build-dotfiles.sh)
├── install_final.sh     # Instala com dotfiles/ definitivo sem rebuild do HyprPunk
├── stow.sh              # Aplica dotfiles/ para ~/.dotfiles e cria symlinks em $HOME
├── lib/common.sh        # Funções compartilhadas
└── README_final.md      # Documentação de instalação definitiva
```

## Quando usar `README_final.md`

Use este README quando você já tiver o `dotfiles/` definitivo no repositório e quiser instalar a sua configuração em uma VM nova sem depender do upstream original.

## Passos para instalar em uma VM Arch Linux zerada

1. Clone o repositório:
```bash
git clone https://github.com/SEU_USUARIO/dot-catppuccin.git ~/dot-catppuccin
cd ~/dot-catppuccin
```

2. Torne os scripts executáveis:
```bash
chmod +x *.sh lib/*.sh
```

3. Execute a instalação definitiva:
```bash
./install_final.sh
```

## O que `install_final.sh` faz

- Verifica se `dotfiles/` existe e não está vazio
- Instala pacotes essenciais via `yay`
- Atualiza o sistema Arch
- Limpa configurações antigas do usuário
- Executa `./stow.sh` para aplicar seus dotfiles definitivos
- Cria `~/.cache/awww`
- Habilita serviços `NetworkManager`, `sddm`, `vmtoolsd`, `xwayland-satellite`
- Configura locale `pt_BR.UTF-8`
- Aplica temas GTK e ícones

## Uso alternativo: apenas dotfiles

Se a VM já tiver todos os pacotes necessários e você só quiser aplicar os dotfiles:

```bash
./stow.sh
```

## Como manter o repositório definitivo

- Versione `dotfiles/` no GitHub para ter controle total
- Inclua seus arquivos de shell em `dotfiles/bash/`:
  - `.bashrc`
  - `.aliases`
  - `.aliases-arch`
  - `.functions`
- Mantenha `install_final.sh` como o instalador definitivo
- Use `build-dotfiles.sh` apenas como referência ou para reconstruções futuras, não como parte da instalação padrão

## Recomendações

- Faça commit de `dotfiles/`, `install_final.sh`, `stow.sh`, `README_final.md` e `README.md`
- Use `install_final.sh` em novas VMs para não depender de fontes externas
- Se precisar atualizar o dotfiles definitivo, edite `dotfiles/` diretamente e versiona no Git

## Resumo

- `./install.sh` = instalação completa que depende do build automático
- `./install_final.sh` = instalação definitiva com seu `dotfiles/` consolidado
- `./stow.sh` = aplica dotfiles existentes ao `HOME`

Se quiser, posso também gerar um `README_release.md` com comandos prontos para clonar e instalar em uma VM limpa.
