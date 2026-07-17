{
  config,
  lib,
  ...
}:

let
  cfg = config.homelab.services.grafana;
in
{
  options.homelab.services.grafana = {
    enable = lib.mkEnableOption "Enable Grafana that interacts with VictoriaMetrics";
    secret = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/secrets/grafana";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 3000;
    };
  };

  config = lib.mkIf cfg.enable {
    services.grafana = {
      enable = true;
      openFirewall = true;
      provision = {
        enable = true;
        datasources.settings.datasources = [
        {
          name = "VictoriaMetrics (control-plane)";
          type = "prometheus";

          # FIXME: currently assumes localhost, this will be improved when nodes will be declared in a nix file
          url = "http://localhost:${toString config.homelab.services.victoria-metrics.port}";

          isDefault = true;
          editable = false;
        }
        ];
      };
      settings = {
        analytics.reporting_enable = false;
        security.secret_key = cfg.secret;
        server = {
          http_addr = "0.0.0.0";
          http_port = cfg.port;
        };
      };
    };
  };
}
