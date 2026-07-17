{
  config,
  lib,
  ...
}:

let
  cfg = config.homelab.services.victoria-metrics;
in
{
  options.homelab.services.victoria-metrics = {
    enable = lib.mkEnableOption "Enable VictoriaMetrics";

    nodes = lib.mkOption {
      type = lib.types.listOf lib.types.nonEmptyStr;
      default = [];
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 8428;
    };
  };

  config = lib.mkIf cfg.enable {
    services.victoriametrics = {
      enable = true;
      retentionPeriod = "3";  # months
      listenAddress = ":${builtins.toString cfg.port}";
      prometheusConfig = {
        scrape_configs = [
          {
            job_name = "node-exporter";
            metrics_path = "/metrics";
            scrape_interval = "15s";
            static_configs = map (node: { targets = ["${node}:${builtins.toString config.homelab.settings.metrics.port}"]; labels.type = "node"; }) cfg.nodes;
          }
        ];
      };
    };
  };
}
