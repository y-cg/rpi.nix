{ lib, ... }:
{
  networking.hostName = "rpi";

  # --- Boot ---------------------------------------------------------------
  boot.loader.grub.enable = false;

  # sd-image pulls in profiles.base, which defaults zfs=true on aarch64.
  # Root is ext4; keeping ZFS enabled forces zfs-kernel (and often a full
  # linux_rpi rebuild) that is not in nixos-raspberrypi.cachix.org.
  # See https://github.com/nvmd/nixos-raspberrypi/issues/172
  boot.supportedFilesystems.zfs = lib.mkForce false;

  # This fix the problem that rpi fail to reconnect to wifi after reboot in a fresh nixos-rebuild
  # See https://github.com/Robertof/nixos-docker-sd-image-builder/issues/10#issuecomment-646901392
  hardware.enableRedistributableFirmware = true; # Includes wifi kernel modules.

  # --- Filesystems --------------------------------------------------------
  fileSystems = {
    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = [
        "noatime"
        "noauto"
        "x-systemd.automount"
        "x-systemd.idle-timeout=1min"
      ];
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  # --- Network: static LAN addressing on the wired interface (no WiFi) ----
  networking.useDHCP = false;
  networking.useNetworkd = true;

  systemd.network = {
    enable = true;
    networks."10-lan" = {
      # Only the onboard NIC (bcmgenet).
      matchConfig = {
        Type = "ether";
        Driver = "bcmgenet";
      };
      address = [ "192.168.3.16/24" ];
      # surge gateway
      gateway = [ "192.168.3.8" ];
      dns = [ "198.18.0.2" ];
      linkConfig.RequiredForOnline = "routable";
    };
  };

  # --- Release ------------------------------------------------------------
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.
  system.stateVersion = "26.05";
}
