{ ... }:

{
  logsHoster = "nixberry";
  perhapsHoster = "nixberry";

  hosts = import ../nodes/host-data.nix;
}
