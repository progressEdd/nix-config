# machines/fishbook/default.nix
{ config, modules, pkgs, host, home-manager, nix-homebrew, lib, ... }:

{
  imports = [
    modules.universal
    modules.macHome  
    home-manager.darwinModules.home-manager
    nix-homebrew.darwinModules.nix-homebrew
    # ../../users/developedd.nix
    ../../users/progressedd.nix
  ];

  nix.enable = true;
  system.primaryUser = "progressedd";

  networking.hostName = host;
  time.timeZone = "America/Chicago";

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "progressedd";
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;       # run `brew update` on activation
      upgrade = true;          # upgrade outdated casks/formulae
      cleanup = "zap";         # remove anything not listed here
    };
    taps = [  ]; # "microsoft/mssql-release"
    brews = [ ]; # "unixodbc" 
    casks = [
      # "obs"
      "betterdisplay"
      "displaylink"
      "firefox@developer-edition"
      "flux-app"
      "itsycal"
      "karabiner-elements"
      "kdenlive"
      "mac-mouse-fix"
      "stats"
      "time-out"
      ];
  };

  system.stateVersion = 5;
}
