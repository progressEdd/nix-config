# machines/fishbook/default.nix
{ config, modules, pkgs, host, home-manager, nix-homebrew, lib, ... }:

{
  imports = [
    modules.universal
    modules.macHome  
    home-manager.darwinModules.home-manager
    nix-homebrew.darwinModules.nix-homebrew
    ../../users/developedd.nix
  ];

  nix.enable = true;
  system.primaryUser = "developedd";

  networking.hostName = host;
  time.timeZone = "America/Chicago";

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
