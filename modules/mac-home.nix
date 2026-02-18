# modules/mac-home.nix - Home Manager configuration for macOS users
{ pkgs, lib, ... }:
let
  user = "progressedd";
  fishPath = "${pkgs.fish}/bin/fish";
in
{
  # Remove /Applications/Xcode.app from sandbox paths (we only have Command Line Tools)
  nix.settings.extra-sandbox-paths = lib.mkForce [
    "/Library/Developer/CommandLineTools"
    "/System/Library/Frameworks"
    "/System/Library/PrivateFrameworks"
  ];

  # macOS-specific home packages (already have some in development.nix)
  # System packages for macOS
  environment.systemPackages = with pkgs; [
    imagemagick
    darwin.lsusb
    # karabiner-elements
    alt-tab-macos
    hidden-bar
    rectangle
    raycast
    iterm2
    vscodium
  ];
  # Enable Fish shell support
  programs.fish.enable = true;
  environment.etc."shells".text = ''
    /bin/bash
    /bin/csh
    /bin/dash
    /bin/ksh
    /bin/sh
    /bin/tcsh
    /bin/zsh
    ${pkgs.fish}/bin/fish
  '';
  # best-effort declarative setting
  users.users.${user}.shell = pkgs.fish;

  # hard-enforce via activation (covers existing users reliably)
  system.activationScripts.setUserShellToFish.text = ''
    set -euo pipefail
    USER="${user}"
    FISH="${fishPath}"

    echo "setUserShellToFish: enforcing $USER -> $FISH"

    current="$(/usr/bin/dscl . -read /Users/$USER UserShell | /usr/bin/awk '{print $2}')"
    echo "setUserShellToFish: current=$current"

    if [ "$current" != "$FISH" ]; then
      /usr/bin/dscl . -change /Users/$USER UserShell "$current" "$FISH" \
        || ( /usr/bin/dscl . -delete /Users/$USER UserShell && /usr/bin/dscl . -create /Users/$USER UserShell "$FISH" )
    fi

    /usr/bin/dscl . -read /Users/$USER UserShell
  '';

  # macOS-specific settings
  system.stateVersion = 5;
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  security.sudo.extraConfig = ''
    # Set timeout to 1 hour (60 minutes)
    Defaults timestamp_timeout=60
  '';
  system.keyboard.enableKeyMapping = true;

  # Configure macOS system defaults
  system.defaults = {
    CustomUserPreferences = {
      "NSGlobalDomain" = {
        "AppleInterfaceStyle" = "Dark";
        "AppleKeyboardUIMode" = 0;
        "AppleMenuBarFontSize" = "large";
        "AppleMenuBarVisibleInFullscreen" = 1;
        "AppleMiniaturizeOnDoubleClick" = 0;
        "AppleShowAllExtensions" = 1;
        "AppleShowAllFiles" = 1;
        "AppleShowScrollBars" = "Always";
        "AppleSpacesSwitchOnActivate" = 1;
        "AppleWindowTabbingMode" = "always";
        "ContextMenuGesture" = 1;
        "InitialKeyRepeat" = 30;
        "KeyRepeat" = 2;
        "NSAutomaticCapitalizationEnabled" = 0;
        "NSAutomaticDashSubstitutionEnabled" = 0;
        "NSAutomaticInlinePredictionEnabled" = 0;
        "NSAutomaticPeriodSubstitutionEnabled" = 0;
        "NSAutomaticQuoteSubstitutionEnabled" = 0;
        "NSAutomaticSpellingCorrectionEnabled" = 0;
        "NSQuitAlwaysKeepsWindows" = 1;
        "NavPanelFileListModeForOpenMode" = 1;
        "WebAutomaticSpellingCorrectionEnabled" = 0;
        "com.apple.keyboard.fnState" = 1;
        "com.apple.mouse.doubleClickThreshold" = "0.15";
        "com.apple.mouse.linear" = 0;
        "com.apple.mouse.scaling" = "0.6875";
        "com.apple.scrollwheel.scaling" = "0.1838";
        "com.apple.sound.beep.flash" = 0;
        "com.apple.sound.beep.volume" = 1;
        "com.apple.springing.delay" = "0.5";
        "com.apple.springing.enabled" = 0;
        "com.apple.swipescrolldirection" = false;
        "com.apple.trackpad.forceClick" = 0;
        "com.apple.trackpad.scaling" = "0.875";
      };
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          # Spotlight search (⌘Space)
          "64" = { enabled = false; };

          # Spotlight Finder search window (⌘⌥Space)
          "65" = { enabled = false; };
        };
      };

      "com.apple.dock" = {
        "autohide" = true;
        "expose-group-apps" = 0;
        "launchanim" = 0;
        "mru-spaces" = 0;
        "orientation" = "right";
        "show-process-indicators" = 0;
        "show-recents" = 0;
        "tilesize" = 38;
        "trash-full" = 1;
        "wvous-br-corner" = 1;
        "wvous-br-modifier" = 0;
      };

      "com.apple.screencapture" = {
        "disable-shadow" = true;
        "location-last" = "~/Pictures/screenshots";
        "showsCursor" = true;
        "target" = "clipboard";
      };

      "com.apple.finder" = {
        "_FXShowPosixPathInTitle" = true;   # show full path in Finder title bar
        "ShowPathbar" = true;               # show path bar at bottom of Finder
        "ShowStatusBar" = true;             # show status bar at bottom of Finder
        "FXPreferredViewStyle" = "Nlsv";    # list view by default
        "AppleShowAllFiles" = true;         # show hidden files
        "FXEnableExtensionChangeWarning" = false;
      };

      "com.apple.menuextra.clock" = {
        "IsAnalog" = 1;
        "ShowAMPM" = 0;
        "ShowDate" = 2;
        "ShowDayOfWeek" = 1;
      };

      "com.apple.WindowManager" = {
        "AppWindowGroupingBehavior" = 1;
        "AutoHide" = 1;
        "EnableStandardClickToShowDesktop" = 0;
        "EnableTiledWindowMargins" = 0;
        "EnableTilingByEdgeDrag" = 0;
        "EnableTilingOptionAccelerator" = 0;
        "EnableTopTilingByEdgeDrag" = 0;
        "GloballyEnabled" = 0;
        "HideDesktop" = 1;
        "StageManagerHideWidgets" = 1;
        "StandardHideDesktopIcons" = 1;
        "StandardHideWidgets" = 1;
      };

      "com.apple.AppleMultitouchTrackpad" = {
        "Clicking" = 0;
        "DragLock" = 0;
        "Dragging" = 0;
        "TrackpadCornerSecondaryClick" = 2;
        "TrackpadFiveFingerPinchGesture" = 0;
        "TrackpadFourFingerHorizSwipeGesture" = 2;
        "TrackpadFourFingerPinchGesture" = 0;
        "TrackpadFourFingerVertSwipeGesture" = 2;
        "TrackpadHandResting" = 1;
        "TrackpadHorizScroll" = 1;
        "TrackpadMomentumScroll" = 1;
        "TrackpadPinch" = 1;
        "TrackpadRightClick" = 0;
        "TrackpadRotate" = 1;
        "TrackpadScroll" = 1;
        "TrackpadThreeFingerDrag" = 0;
        "TrackpadThreeFingerHorizSwipeGesture" = 2;
        "TrackpadThreeFingerTapGesture" = 0;
        "TrackpadThreeFingerVertSwipeGesture" = 2;
        "TrackpadTwoFingerDoubleTapGesture" = 1;
        "TrackpadTwoFingerFromRightEdgeSwipeGesture" = 0;
        "USBMouseStopsTrackpad" = 0;
      };

      "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
        "Clicking" = 0;
        "DragLock" = 0;
        "Dragging" = 0;
        "TrackpadCornerSecondaryClick" = 2;
        "TrackpadFiveFingerPinchGesture" = 0;
        "TrackpadFourFingerHorizSwipeGesture" = 2;
        "TrackpadFourFingerPinchGesture" = 0;
        "TrackpadFourFingerVertSwipeGesture" = 2;
        "TrackpadHandResting" = 1;
        "TrackpadHorizScroll" = 1;
        "TrackpadMomentumScroll" = 1;
        "TrackpadPinch" = 1;
        "TrackpadRightClick" = 0;
        "TrackpadRotate" = 1;
        "TrackpadScroll" = 1;
        "TrackpadThreeFingerDrag" = 0;
        "TrackpadThreeFingerHorizSwipeGesture" = 2;
        "TrackpadThreeFingerTapGesture" = 0;
        "TrackpadThreeFingerVertSwipeGesture" = 2;
        "TrackpadTwoFingerDoubleTapGesture" = 1;
        "TrackpadTwoFingerFromRightEdgeSwipeGesture" = 0;
        "USBMouseStopsTrackpad" = 0;
      };

    "com.raycast.macos" = {
      "raycastGlobalHotkey" = "Control-49";
      "raycastPreferredWindowMode" = "default";
      "raycastShouldFollowSystemAppearance" = 1;

      "raycastFirstKnownAppVersion" = "1.75.1";
      "raycastInstallationDate" = "2024-05-28 04:12:05 +0000";
      "raycastLoginItemAutoInstalled" = "2024-05-28 04:12:07 +0000";

      "raycast-updates-lastAppUpdateCheckDate" = "1766088877.565282";
      "raycast-updates-lastTargetCommitishInstalled" = "aec80c854b0076d640afa2b348f855bd74584256";
      "raycast-updates-whatsNewItemDisplayDate" = "1765902913.503413";

      "raycast-startFocusSession-filter-mode" = "block";
      "raycast-startFocusSession-duration" = null;
      "raycast-startFocusSession-title" = "";
      "raycast-startFocusSession-blockable-items" = [ ];

      "onboardingCompleted" = 1;
      "onboarding_raycastShortcuts" = [ "⌘W" "⌘," "Esc" "⌘Esc" ];
    };

    "com.knollsoft.Rectangle" = {
      "SUEnableAutomaticChecks" = 0;
      "SUHasLaunchedBefore" = 1;
      "SULastCheckTime" = "2025-01-21 17:59:06 +0000";

      "allowAnyShortcut" = 1;
      "alternateDefaultShortcuts" = 1;
      "launchOnLogin" = 1;
      "subsequentExecutionMode" = 1;
      "internalTilingNotified" = 1;

      "reflowTodo" = { "keyCode" = 45; "modifierFlags" = 786432; };
      "toggleTodo" = { "keyCode" = 11; "modifierFlags" = 786432; };

      "disabledApps" = "[]";
      "landscapeSnapAreas" = null;
      "portraitSnapAreas" = null;

      "lastVersion" = 91;
    };

    # "com.lwouis.alt-tab-macos" = {
    #   "menubarIconShown" = true;
    #   "preferencesVersion" = "7.36.0";

    #   "SUHasLaunchedBefore" = 1;
    #   "SULastCheckTime" = "2025-12-12 18:09:25 +0000";
    #   "updatePolicy" = 1;

    #   "holdShortcut" = "⌥";
    #   "nextWindowShortcut" = "⇥";
    #   "nextWindowShortcut2" = "`";

    #   "windowMaxWidthInRow" = 30;
    # };
    };
  };

  
}

