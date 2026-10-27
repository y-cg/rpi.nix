{ inputs, pkgsNightly, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";

    # Home Manager runs as a separate module evaluation, so pass the
    # flake inputs and nightly packages through explicitly.
    extraSpecialArgs = { inherit inputs pkgsNightly; };

    users.ycg.imports = [
      ../modules/home-manager
      ../home
    ];
  };
}
