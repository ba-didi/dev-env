{
  description = "My personal dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nixpkgs, home-manager, ... }@ inputs:
    let
      
      pkgs = import nixpkgs { inherit system; };
      local = import ./local.nix;
      username = local.username;
      homeDir = local.homeDir;
      system = local.system;
    in {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = { inherit self inputs; };
        inherit pkgs;
        modules = [
          ({ config, pkgs, self, ... }: {
            home.username = username;
            home.homeDirectory = homeDir;
          })
          ./base.nix
        ];
      };
    };
}

