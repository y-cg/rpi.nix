{
  description = "YCG's NixOS (Raspberry Pi)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Track main: the nixos-26.05 branch is frozen on a July pin whose
    # linux_rpi4 build has already aged out of nixos-raspberrypi.cachix.org.
    # main (and develop) still have substitutable vendor kernels.
    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/main";
    };
    nix4nvchad = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nvchad-starter.follows = "nvchad-config";
    };
    nvchad-config = {
      url = "github:y-cg/nvchad";
      flake = false;
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./flakes/nixosConfig.nix
        ./flakes/image.nix
      ];
    };
}
