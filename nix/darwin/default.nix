{ config, pkgs, lib, ... }:
{
  imports = [
    ./homebrew.nix
  ];

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
  };

  services.nix-daemon.enable = true;

  programs.zsh.enable = true;

  users.users.drew = {
    home = "/Users/drew";
    createHome = false;
    shell = pkgs.zsh;
  };

  fonts = {
    fontDir.enable = true;
    fonts = [
      (pkgs.nerdfonts.override {
        fonts = [
          "JetBrainsMono"
          "FiraCode"
          "NerdFontsSymbolsOnly"
        ];
      })
    ];
  };

  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      ApplePressAndHoldEnabled = false;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      NSDocumentSaveNewDocumentsToCloud = false;
    };

    "com.apple.finder" = {
      ShowStatusBar = true;
      ShowPathbar = true;
      FXDefaultSearchScope = "SCcf";
      FXPreferredViewStyle = "Nlsv";
    };

    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.2;
      persistent-apps = [
        "/Applications/Visual Studio Code.app"
        "/Applications/Ghostty.app"
        "/Applications/Obsidian.app"
        "/Applications/draw.io.app"
      ];
    };
  };

  system.activationScripts.postActivation.text = ''
    /usr/bin/chflags nohidden "$HOME/Library" || true
  '';

  environment.systemPackages = with pkgs; [
    vim
    git
    gnupg
  ];

  system.stateVersion = 5;
}
