{ ... }:
{
  imports = [
    ./options.nix
    ./loki.nix
    ./prometheus.nix
    ./grafana.nix
    ./prometheus.nix
    ./promtail.nix
    ./nginx
    ./users.nix
  ];
}
