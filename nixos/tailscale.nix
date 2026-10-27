{ pkgsNightly, ... }:
{
  services.tailscale = {
    enable = false; # bug, enable later
    package = pkgsNightly.tailscale;
    authKeyFile = "/etc/tailscale/key";
    openFirewall = true;
  };
}
