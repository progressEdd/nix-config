{ config, modules, pkgs, host, home-manager, nix-homebrew, nixos-hardware, ... }:

{
  imports = [
    modules.universal
    modules.macHome
    home-manager.darwinModules.home-manager
    nix-homebrew.darwinModules.nix-homebrew
    # ../../users/progressedd.nix
    ../../users/developedd.nix
  ];

  networking.hostName  = host;

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
