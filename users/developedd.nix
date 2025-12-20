# users/developedd.nix  (Home Manager module)
{ pkgs, lib, ... }:

let
  username = "developedd";
  homeDir = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
in
{
  home.username = username;
  home.homeDirectory = homeDir;

  imports = [
    ../modules/development.nix
    ../dotfiles/multiple-ssh.nix
  ];

  home.file.".config/karabiner/karabiner.json".source = ../dotfiles/karabiner.json;

  programs.fish.enable = true;

  home.packages = with pkgs; [
    colima
    code-cursor
    ollama
    obs-studio
  ];
}
