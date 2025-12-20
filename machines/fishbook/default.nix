# machines/fishbook/default.nix
{ config, modules, pkgs, host, home-manager, nix-homebrew, ... }:

{
  imports = [
    modules.universal
    modules.macHome
    home-manager.darwinModules.home-manager
    nix-homebrew.darwinModules.nix-homebrew
  ];

  nix.enable = true;
  system.primaryUser = "developedd";

  networking.hostName = host;
  time.timeZone = "America/Chicago";

  # Home Manager: developedd only (test)
  home-manager.users = {
    developedd = {
      home = {
        username = "developedd";
        homeDirectory = /Users/developedd;
        stateVersion = "25.05";
      };

      imports = [
        ../../users/developedd.nix
      ];
    };
  };

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "developedd";
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    taps = [ "microsoft/mssql-release" ];
    brews = [ "unixodbc" ];
  };

  system.stateVersion = 5;
}
