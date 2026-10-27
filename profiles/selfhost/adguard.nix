{ lib, ... }:
let
  port = 3003;
in
{
  networking.firewall.allowedTCPPorts = [
    53
    port # adguard home web
  ];

  networking.firewall.allowedUDPPorts = [
    53
  ];

  services.adguardhome = {
    enable = true;
    host = "0.0.0.0";
    port = port;
    settings = {
      dns = {
        upstream_dns = [
          "9.9.9.9#dns.quad9.net"
          "149.112.112.112#dns.quad9.net"
        ];
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
        parental_enabled = false; # Parental control-based DNS requests filtering.
        safe_search = {
          enabled = false; # Enforcing "Safe search" option for search engines, when possible.
        };
      };
      # The following notation uses map to not have to manually create {enabled = true; url = "";} for every filter
      filters =
        map
          (url: {
            enabled = true;
            url = url;
          })
          [
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt" # The Big List of Hacked Malware Web Sites
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt" # Malicious url blocklist
          ];
    };
  };
}
