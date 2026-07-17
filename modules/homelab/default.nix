{ ... }:
{
  imports = [
    ./settings.nix
    ./monitoring.nix
    ./victoria-metrics.nix
    ./grafana.nix
  ];
}
