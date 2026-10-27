{
  meta,
  config,
  lib,
  ...
}:
let
  # Static LAN addressing (wired only; WiFi is not used)
  lanPrefix = "192.168.3";
  gateway = "${lanPrefix}.8";
  address = "${lanPrefix}.16";
in
{
  networking.hostName = meta.hostname;
  # help nixos infer the fqdn
  networking.domain = lib.mkIf config.services.avahi.enable config.services.avahi.domainName;

  networking.networkmanager.enable = false;
  networking.wireless.enable = false;
  networking.useDHCP = false;
  networking.useNetworkd = true;

  systemd.network = {
    enable = true;
    networks."10-lan" = {
      # Match any ethernet device (eth0 / end0 / ...) instead of a fixed name
      matchConfig.Type = "ether";
      address = [ "${address}/24" ];
      gateway = [ gateway ];
      # surge gateway
      dns = [ "198.18.0.2" ];
      linkConfig.RequiredForOnline = "routable";
    };
  };

  networking.firewall = {
    enable = true;
    # make sure mihomo won't be blocked
    # https://blog.nyaw.xyz/nixos-inwall-install
    trustedInterfaces = [
      # common interface name used by mihomo
      "Meta"
      "Mihomo"
      "utun0"
      # docker related
      "docker0"
      "br-+" # docker bridge start with `br-`
    ];
    checkReversePath = false;
  };
}
