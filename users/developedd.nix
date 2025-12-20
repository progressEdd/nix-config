# users/developedd.nix  (Home Manager module)
{ pkgs, ... }:

{
  home.username = "developedd";
  home.homeDirectory = /Users/developedd;

  # Required by Home Manager; choose a version and keep it stable
  home.stateVersion = "25.05";

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
