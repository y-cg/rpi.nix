{ inputs, pkgs, ... }:
let
  pkgsNightly = inputs.nixpkgs-nightly.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.packages = with pkgsNightly; [
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
