{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nix-search-cli
    nixfmt
    nixd
    nil
    nix-output-monitor
  ];
}
