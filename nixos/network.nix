{
  config,
  lib,
  ...
}:
{
  # help nixos infer the fqdn
  networking.domain = lib.mkIf config.services.avahi.enable config.services.avahi.domainName;

  # Headless: no NetworkManager / WiFi
  networking.networkmanager.enable = false;
  networking.wireless.enable = false;

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

  # Enable mDNS with avahi
  # Then it is accessible via ssh username@hostname.local
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    # ref: https://www.reddit.com/r/NixOS/comments/qszvd4/comment/hkgai7j/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };
}
