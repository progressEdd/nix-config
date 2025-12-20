# users/progressedd.nix
{ config, pkgs, home-manager, plasma-manager, lib, ... }:

let
  username     = "developedd";
  userPackages = with pkgs; [
    # add account specific packages here
    colima
    code-cursor
    ollama
    obs-studio
  ];
  
  # Determine home directory based on OS
  homeDir = if pkgs.stdenv.isDarwin 
            then "/Users/${username}"
            else "/home/${username}";
in
{
  users.users.${username} = lib.mkMerge [
    # Linux-specific config
    (lib.mkIf pkgs.stdenv.isLinux {
      isNormalUser = true;
      home         = homeDir;
      extraGroups  = [ "wheel" ];
    })
    # macOS-specific config
    (lib.mkIf pkgs.stdenv.isDarwin {
      home = homeDir;
    })
  ];

  home-manager.users.${username} = {
    home.username      = username;
    home.homeDirectory = homeDir;
    imports = [
      ../modules/development.nix
      ../dotfiles/multiple-ssh.nix
    ];
    home.file.".config/karabiner/karabiner.json".source = ../dotfiles/karabiner.json;
    programs.fish.enable = true;
    home.packages        = userPackages;
  };
}
