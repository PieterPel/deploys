{ pkgs, compose2nix }:

{
  mkComposeApp =
    { name
    , composeFile
    , runtime ? "podman"
    , dataDir ? "/var/lib/${name}"
    ,
    }:

    pkgs.stdenv.mkDerivation {
      name = "${name}-compose-app";
      src = composeFile;

      buildInputs = [
        compose2nix
        pkgs.podman
        pkgs.podman-compose
      ];

      installPhase = ''
                mkdir -p $out

                compose2nix \
                  --input $src \
                  --output $out/containers.nix \
                  --runtime ${runtime} \
                  --data_dir ${dataDir} \
                  --auto_start=true \
                  --default_stop_timeout=10

                cp $src $out/docker-compose.yml

                cat > $out/start <<EOF
        #!/bin/sh
        set -e
        cd $(dirname "$0")
        podman-compose -f docker-compose.yml up -d
        EOF
                chmod +x $out/start
      '';
    };
}
