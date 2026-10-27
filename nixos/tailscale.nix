{ pkgsNightly, ... }:
{
  services.tailscale = {
    enable = true;
    package = pkgsNightly.tailscale;
    openFirewall = true;
  };
}
