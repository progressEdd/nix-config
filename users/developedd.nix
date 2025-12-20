# users/developedd.nix (HM shared module; no home.username/homeDirectory here)
{ pkgs, ... }:

{
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
