{ pkgs, compose2nix }:

{
  mkComposeApp =
    { name
    , composeFile
    , runtime ? "podman"
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

      phases = "unpackPhase installPhase";

      unpackPhase = "true"; # skip unpacking since this is a single file

      installPhase = ''
                mkdir -p $out

                compose2nix \
                  --inputs "$src" \
                  --output $out/containers.nix \
                  --runtime ${runtime} \
                  --auto_start=true \
                  --default_stop_timeout=10s

                cp "$src" $out/docker-compose.yml

                cat > $out/start <<EOF
        #!/bin/sh
        set -e
        cd \$(dirname "\$0")
        podman-compose -f docker-compose.yml up -d
        EOF
                chmod +x $out/start
      '';
    };
}
