{ lib, ... }:

{
  options.homelab.settings = lib.mkOption {
    type = lib.types.attrsOf lib.types.anything;
  };

  config.homelab.settings = {
    metrics.port = 9100;
  };
}
