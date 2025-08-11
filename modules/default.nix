{ ... }:
{
  imports = [
    ./options.nix
    ./loki.nix
    ./prometheus.nix
    ./grafana.nix
    ./prometheus.nix
    ./promptail.nix
    ./nginx
  ];
}
