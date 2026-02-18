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
    home.file."Library/Services".source = ../dotfiles/macos/Services;

    home.activation.statsPrefs = ''
      /usr/bin/defaults import eu.exelban.Stats \
        "${../dotfiles/macos/plists/Stats.plist}"
      /usr/bin/killall Stats 2>/dev/null || true
    '';

    home.activation.rectanglePrefs = ''
      /usr/bin/defaults import com.knollsoft.Rectangle \
        "${../dotfiles/macos/plists/Rectangle.plist}"
      /usr/bin/killall Rectangle 2>/dev/null || true
    '';

    home.activation.raycastPrefs = ''
      /usr/bin/defaults import com.raycast.macos \
        "${../dotfiles/macos/plists/Raycast.plist}"
    '';

    home.activation.altTabPrefs = ''
      /usr/bin/defaults import com.lwouis.alt-tab-macos \
        "${../dotfiles/macos/plists/AltTab.plist}"
      /usr/bin/killall AltTab 2>/dev/null || true
    '';

    home.activation.hiddenBarPrefs = ''
      /usr/bin/defaults import com.dwarvesv.minimalbar \
        "${../dotfiles/macos/plists/HiddenBar.plist}"
      /usr/bin/killall "Hidden Bar" 2>/dev/null || true
    '';

    xdg.enable = true;

    xdg.configFile."karabiner/karabiner.json" = {
      source = ../dotfiles/karabiner.json;
      force = true;
    };
  };
}
