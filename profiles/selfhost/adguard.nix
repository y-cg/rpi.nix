{ lib, ... }:
let
  port = 3003;
  dnsPort = 1053;
in
{
  networking.firewall.allowedTCPPorts = [
    dnsPort
    port # adguard home web
  ];

  networking.firewall.allowedUDPPorts = [
    dnsPort
  ];

  services.adguardhome = {
    enable = true;
    host = "0.0.0.0";
    port = port;
    settings = {
      dns = {
        port = dnsPort;
        upstream_dns = [
          "tls://dns.quad9.net"
        ];
        # Used to resolve the DoT upstream hostname above
        bootstrap_dns = [
          "9.9.9.9"
          "149.112.112.112"
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
