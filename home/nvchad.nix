{ inputs, pkgs, ... }:
let
  pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.packages = with pkgs-unstable; [
    tombi
    prettier
  ];

  imports = [ inputs.nix4nvchad.homeManagerModules.default ];

  programs.nvchad = {
    enable = true;
    hm-activation = true;
    backup = false;
  };

}
