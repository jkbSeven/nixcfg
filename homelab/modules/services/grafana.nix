{
  config,
  lib,
  ...
}:

let
  cfg = config.homelab.services.grafana;
  domain = config.homelab.settings.domain;
  secretsDir = config.homelab.settings.secretsDir;
in
{
  options.homelab.services.grafana = {
    enable = lib.mkEnableOption "Enable Grafana that interacts with VictoriaMetrics";

    port = lib.mkOption {
      type = lib.types.int;
      default = 3000;
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.grafana = {
      file = secretsDir + /grafana.age;
      owner = config.systemd.services.grafana.serviceConfig.User;
      mode = "0400";
    };

    services.grafana = {
      enable = true;

      provision = {
        enable = true;
        datasources.settings.datasources = [
        {
          name = "Control Plane";
          type = "prometheus";

          # FIXME: currently assumes Victoria Metrics is on the same host
          url = "http://localhost:${toString config.homelab.services.victoria-metrics.port}";

          isDefault = true;
          editable = false;
        }
        ];
      };

      settings = {
        analytics.reporting_enable = false;

        # the $__file{} syntax makes Grafana read the file instead of treating the path itself as a secret
        # https://grafana.com/docs/grafana/v13.2/setup-grafana/configure-grafana/#file-provider
        security.secret_key = "\$__file{${config.age.secrets.grafana.path}}";

        server = {
          http_addr = "0.0.0.0";
          http_port = cfg.port;
          domain = domain;
        };

      };
    };

    homelab.proxy.virtualHosts."grafana.${domain}" = {
      locations."/" = {
        proxyPass = "http://${config.homelab.settings.thisNodeFqdn}:${builtins.toString cfg.port}";
        proxyWebsockets = true;
        extraConfig = "proxy_pass_header Authorization;";
      };
    };

    networking.nftables.enable = true;
    networking.firewall.extraInputRules = "ip saddr ${config.homelab.settings.proxyIp} tcp dport ${builtins.toString cfg.port} accept";
  };
}
