# machines/fishbook/default.nix
{ config, modules, pkgs, host, home-manager, nix-homebrew, lib, ... }:

{
  imports = [
    modules.universal
    modules.macHome  
    home-manager.darwinModules.home-manager
    nix-homebrew.darwinModules.nix-homebrew
    ../../users/developedd.nix
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
    taps = [  ]; # "microsoft/mssql-release"
    brews = [ ]; # "unixodbc" 
    casks = [
      # "obs"
      ];
  };

  system.stateVersion = 5;
}
