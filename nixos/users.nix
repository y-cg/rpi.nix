{ pkgs, ... }:
{
  security.sudo.wheelNeedsPassword = false;
  users.users.ycg = {
    createHome = true;
    home = "/home/ycg";
    isNormalUser = true;
    hashedPassword = ""; # Empty password
    # System users in NixOS don't get a login shell by default
    shell = pkgs.zsh;
    extraGroups = [
      "wheel" # allow sudo access
      "docker" # run docker command without sudo
    ];
    group = "users";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHl4c+mtLFx/KtE1OefdP706E/HEbV4+xraGGcxRo6vl"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBIocZKj9aUASAoZtH0PuS2cIBipME9DQo9fKFIMr+D9"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMyydcoM0Zqf+xCVMh4mSVxEVcJ4j5urn/2T0qU0R8lK"
    ];
  };
  programs.zsh.enable = true;
}
