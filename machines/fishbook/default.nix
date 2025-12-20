{ config, modules, pkgs, host, home-manager, nix-homebrew, nixos-hardware, ... }:

{
  imports = [
    modules.universal
    home-manager.darwinModules.home-manager
    nix-homebrew.darwinModules.nix-homebrew
    ../../users/progressedd.nix
  ];

  networking.hostName  = host;
  my.isLaptop          = false;

  time.timeZone        = "America/Chicago";

  # nix-homebrew configuration
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "developedd";
    autoMigrate = true;
  };

  # Homebrew packages
  homebrew = {
    enable = true;
    taps = ["microsoft/mssql-release"];
    brews = [
      "unixodbc"
      # "msodbcsql18"  # optional
    ];
  };

  system.stateVersion = 5;
}
