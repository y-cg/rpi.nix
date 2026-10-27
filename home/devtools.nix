{ pkgs, pkgsNightly, ... }:
{
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # compilers
    gcc
    gnumake
    # git
    gh
    git
    lazygit
    # utils
    fastfetch
    btop
    ripgrep
    fd
    dust
    otree
    flamelens
    nettools
    tlrc
    # shell
    starship
    zsh
    eza
    zoxide
    fzf
    # dev tools
    devenv
    direnv
    # docker
    lazydocker
    dive
    # python
    uv
    # cryptography tools
    age
    sops
    ssh-to-age
    openssl
  ];
}
