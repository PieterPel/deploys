{ pkgs
, ...
}:
let
  username = "deploy";
in
{
  users.users.${username} = {
    isNormalUser = true;
    description = "Deploy user";
    home = "/home/${username}";
    shell = pkgs.bash;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDoxYGLFuZ7wTyCC2gHC/dcygvNkpe4naF535krnYnvp pelpieter@gmail.com"
    ];
  };
}
