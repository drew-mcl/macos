{ config, pkgs, lib, ... }:
let
  dotfiles = ../../dotfiles;
in {
  home = {
    username = "drew";
    homeDirectory = "/Users/drew";
    stateVersion = "23.11";

    activation = {
      ensureDevDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/repos/personal" "$HOME/repos/work" "$HOME/repos/archive"
        mkdir -p "$HOME/.local/bin" "$HOME/bin" "$HOME/tmp"
      '';
    };

    packages = with pkgs; [
      ansible
      bat
      consul
      coreutils
      delta
      direnv
      eza
      fd
      fzf
      gh
      git
      git-cliff
      glab
      gnumake
      jq
      kubernetes-helm
      kubectl
      lazygit
      libffi
      libyaml
      mise
      openssl
      pipx
      pkg-config
      python311Packages.gitlint
      python311Packages.commitizen
      readline
      ripgrep
      stow
      starship
      terraform
      tree
      watchman
      wget
      zsh-autosuggestions
      zsh-syntax-highlighting
    ];
  };

  programs.home-manager.enable = true;

  xdg = {
    enable = true;

    configFile = {
      "direnv/direnv.toml".source = "${dotfiles}/direnv/.config/direnv/direnv.toml";
      "ghostty/config".source = "${dotfiles}/ghostty/.config/ghostty/config";
      "git/hooks" = {
        source = "${dotfiles}/git/.config/git/hooks";
        recursive = true;
      };
      "glab-cli/config.yml".source = "${dotfiles}/glab/.config/glab-cli/config.yml";
      "mise/config.toml".source = "${dotfiles}/mise/.config/mise/config.toml";
      "starship.toml".source = "${dotfiles}/starship/.config/starship.toml";
    };
  };

  home.file = {
    ".curlrc".source = "${dotfiles}/curl/.curlrc";
    ".gitconfig".source = "${dotfiles}/git/.gitconfig";
    ".gitattributes".source = "${dotfiles}/git/.gitattributes";
    ".gradle/gradle.properties".source = "${dotfiles}/gradle/.gradle/gradle.properties";
    ".bundle/config".source = "${dotfiles}/ruby/.bundle/config";
    ".default-gems".source = "${dotfiles}/ruby/.default-gems";
    ".gemrc".source = "${dotfiles}/ruby/.gemrc";
    ".irbrc".source = "${dotfiles}/ruby/.irbrc";
    ".ssh/config".source = "${dotfiles}/ssh/.ssh/config";
    ".ssh/config.d" = {
      source = "${dotfiles}/ssh/.ssh/config.d";
      recursive = true;
    };
    ".local/bin/git-cliff-completions" = {
      source = "${dotfiles}/zsh/.local/bin/git-cliff-completions";
      executable = true;
    };
    ".zprofile".source = "${dotfiles}/zsh/.zprofile";
    ".zshrc".source = "${dotfiles}/zsh/.zshrc";
    "Library/Application Support/Code/User/settings.json".source =
      "${dotfiles}/vscode/Library/Application Support/Code/User/settings.json";
  };
}
