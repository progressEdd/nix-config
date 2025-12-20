# users/developedd.nix (Home Manager module)
{ pkgs, ... }:

let
  username = "developedd";
  homeDirStr = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
in
{
  home.username = username;
  home.homeDirectory = builtins.toPath homeDirStr;

  # set this somewhere in HM (if not already set in another imported HM module)
  # home.stateVersion = "25.11";

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
