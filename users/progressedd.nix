# users/developedd.nix
{ config, pkgs, lib, ... }:

let
  username = "progressedd";

  homeDir =
    if pkgs.stdenv.isDarwin
    then "/Users/${username}"
    else "/home/${username}";

  userPackages = with pkgs; [
    colima
    code-cursor
    ollama
    # obs-studio
  ];
in
{
  users.users.${username} = lib.mkMerge [
    (lib.mkIf pkgs.stdenv.isLinux {
      isNormalUser = true;
      home = homeDir;
      extraGroups = [ "wheel" ];
    })
    (lib.mkIf pkgs.stdenv.isDarwin {
      home = homeDir;
    })
  ];

  home-manager.users.${username} = {
    home.username = username;
    home.homeDirectory = homeDir;
    home.stateVersion = "25.05";

    imports = [
      # ../modules/mac-home.nix
      ../modules/development.nix
      ../dotfiles/multiple-ssh.nix
    ];
    home.packages = userPackages;
  };
}
