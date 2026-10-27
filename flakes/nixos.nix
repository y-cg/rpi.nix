{ inputs, ... }:
let
  pkgsNightly = import inputs.nixpkgs-nightly {
    system = "aarch64-linux";
    config.allowUnfree = true;
  };
in
{
  flake.nixosConfigurations.rpi = inputs.nixos-raspberrypi.lib.nixosSystem {
    system = "aarch64-linux";
    specialArgs = { inherit inputs pkgsNightly; };
    modules = [
      ../nixos
      ../profiles/selfhost
      ../hosts/rpi
      inputs.nixos-raspberrypi.nixosModules.sd-image
      inputs.nixos-raspberrypi.nixosModules.raspberry-pi-4.base
      inputs.home-manager.nixosModules.default
    ];
  };
}
