# Grafana — dashboarding/visualization front end.
# Exposed on the LAN (0.0.0.0:3000); proxies the Loki/Tempo/Mimir datasources
# over loopback.
{ ... }:
let
  ports = import ./ports.nix;
in
{
  networking.firewall.allowedTCPPorts = [ ports.grafana ];

  # nixos-26.05 removed Grafana's default `secret_key`. We must provide one,
  # but it must NOT live in the world-readable Nix store. Instead we generate
  # a random key into a root/grafana-owned file on first boot and reference it
  # via Grafana's file-provider (`$__file{...}`).
  # See https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/#file-provider
  systemd.services.grafana-secret-key = {
    description = "Generate Grafana secret_key file";
    before = [ "grafana.service" ];
    requiredBy = [ "grafana.service" ];
    unitConfig = {
      # grafana.service declares Restart=on-failure and is wanted by
      # multi-user.target; regenerate-or-leave alone is idempotent either way.
      ConditionPathExists = "!/var/lib/grafana/secret_key";
    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      UMask = "0077";
    };
    script = ''
      install -d -o grafana -g grafana -m 0750 /var/lib/grafana
      # 32 random bytes -> 64 hex chars (pure coreutils, works on the target)
      key=$(head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n')
      install -o grafana -g grafana -m 0400 /dev/stdin /var/lib/grafana/secret_key <<<"$key"
    '';
  };

  services.grafana = {
    enable = true;
    settings = {
      security.secret_key = "$__file{/var/lib/grafana/secret_key}";
      server = {
        http_addr = "0.0.0.0";
        http_port = ports.grafana;
        domain = "localhost";
      };
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Mimir";
          uid = "mimir";
          type = "prometheus";
          access = "proxy";
          url = "http://127.0.0.1:${toString ports.mimir}/prometheus";
          isDefault = true;
        }
        {
          name = "Loki";
          uid = "loki";
          type = "loki";
          access = "proxy";
          url = "http://127.0.0.1:${toString ports.loki}";
          jsonData.maxLines = 1000;
        }
        {
          name = "Tempo";
          uid = "tempo";
          type = "tempo";
          access = "proxy";
          url = "http://127.0.0.1:${toString ports.tempo}";
          jsonData = {
            serviceMap.enabled = true;
            tracesToLogsV2 = {
              datasourceUid = "loki";
              spanStartTimeShift = "1h";
              spanEndTimeShift = "1h";
              filterByTraceID = true;
              filterBySpanID = true;
              tags = [ "service.name" ];
            };
          };
        }
      ];
    };
  };
}
