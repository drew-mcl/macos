{
  description = "nix-darwin + home-manager rewrite of the laptop-setup repo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "darwin";
    };
  };

  outputs = inputs@{ self, nixpkgs, darwin, home-manager, nix-homebrew, ... }:
    let
      system = "aarch64-darwin"; # change to "x86_64-darwin" for Intel Macs
      user = "drew";
      homeModule = ./nix/home/drew.nix;
    in {
      darwinConfigurations."drew-mbp" = darwin.lib.darwinSystem {
        inherit system;
        modules = [
          ./nix/darwin/default.nix

          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew

          {
            nix-homebrew = {
              enable = true;
              user = user;
              autoMigrate = true;
            };

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${user} = import homeModule;
          }
        ];
      };

      homeConfigurations."${user}@darwin" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        modules = [
          homeModule
        ];
      };
    };
}
