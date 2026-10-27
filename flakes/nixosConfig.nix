{
  inputs,
  ...
}:
let
  lib = import ../lib;
  inherit (inputs) nixpkgs nixpkgs-unstable;
  mkNixosSystem =
    {
      meta,
      nixosModules,
      homeManagerModules,
      extraSpecialArgs ? { },
      f ? nixpkgs.lib.nixosSystem,
      ...
    }:
    let
      pkgs-unstable = import nixpkgs-unstable {
        system = meta.system;
        config.allowUnfree = true;
      };
      specialArgs = {
        inherit
          inputs
          nixpkgs-unstable
          pkgs-unstable
          meta
          ;
        sealed = lib.sealed;
      }
      // extraSpecialArgs;
      homeManagerInjection = lib.injectHomeManager {
        inherit (meta) whoami;
        inherit homeManagerModules;
        extraSpecialArgs = specialArgs;
      };
    in
    f {
      inherit (meta) system;
      inherit specialArgs;
      modules = nixosModules ++ [
        inputs.home-manager.nixosModules.default
        homeManagerInjection
      ];
    };
in
{
  systems = [ ];
  flake =
    { ... }:
    {
      nixosConfigurations = {
        rpi = mkNixosSystem (import ../configurations/rpi4.nix { inherit inputs; });
      };
    };
}
