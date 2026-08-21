{
  description = "My first flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nvf.url = "github:NotAShelf/nvf";
    home-manager.url = "github:nix-community/home-manager";
    extest.url = "github:chaorace/extest-nix";
  };

  outputs = { self, nixpkgs, nvf, extest, home-manager }: {
      homeConfigurations."sam@nixos" = home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs.legacyPackages.x86_64-linux;
              modules = [
                nvf.homeManagerModules.default
                ./home.nix
              ];
      };

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        modules = [
            ./configuration.nix
            nvf.nixosModules.default
                {
                        nixpkgs.overlays = [ 
                                extest.overlays.default
                        ];
                }
      ];
    };
  };
}
