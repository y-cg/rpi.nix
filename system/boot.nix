{ lib, ... }:
{
  boot.loader.grub.enable = false;

  # sd-image pulls in profiles.base, which defaults zfs=true on aarch64.
  # Root is ext4; keeping ZFS enabled forces zfs-kernel (and often a full
  # linux_rpi rebuild) that is not in nixos-raspberrypi.cachix.org.
  # See https://github.com/nvmd/nixos-raspberrypi/issues/172
  boot.supportedFilesystems.zfs = lib.mkForce false;

  # This fix the problem that rpi fail to reconnect to wifi after reboot in a fresh nixos-rebuild
  # See https://github.com/Robertof/nixos-docker-sd-image-builder/issues/10#issuecomment-646901392
  hardware.enableRedistributableFirmware = true; # Includes wifi kernel modules.
}
