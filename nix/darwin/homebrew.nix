{ lib, ... }:
{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      cleanup = "zap";
      upgrade = false;
    };

    taps = [
      "homebrew/cask"
      "homebrew/cask-fonts"
    ];

    brews = [ ];

    casks = [
      "ghostty"
      "obsidian"
      "intellij-idea"
      "visual-studio-code"
      "drawio"
    ];
  };
}
