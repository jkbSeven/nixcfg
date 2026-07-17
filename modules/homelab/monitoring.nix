{
  config,
  lib,
  ...
}:

let
  cfg = config.homelab.monitoring;
in
{
  options = {
    homelab.monitoring.enable = lib.mkEnableOption "Enable metrics collection from node";
  };

  config = lib.mkIf cfg.enable {
    services.prometheus.exporters.node = {
      enable = true;
      openFirewall = true;
      port = config.homelab.settings.metrics.port;
    };
  };
}
