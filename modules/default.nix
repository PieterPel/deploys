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
    ./app-users.nix
    ./deploy-user.nix
    ./host-data.nix
  ];
}
