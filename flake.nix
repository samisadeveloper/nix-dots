{
        description = "My first flake";

        inputs = {
                nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
                nvf.url = "github:NotAShelf/nvf";
                home-manager.url = "github:nix-community/home-manager";
                extest.url = "github:chaorace/extest-nix";

                spicetify-nix.url = "github:Gerg-L/spicetify-nix";

                caelestia-shell = {
                        url = "github:caelestia-dots/shell";
                        inputs.nixpkgs.follows = "nixpkgs";
                };

                quickshell-overview = {
                        url = "github:Shanu-Kumawat/quickshell-overview";
                        flake = false;
                };
        };

        outputs = { self, nixpkgs, ... } @inputs:
                let
                system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        vice = pkgs.callPackage ./apps/vice-app.nix { };
        in {
                homeConfigurations."sam@nixos" = inputs.home-manager.lib.homeManagerConfiguration {
                        pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux; # so is this just a variable or what?
                                extraSpecialArgs = { inherit inputs; };
                        modules = [
                                inputs.nvf.homeManagerModules.default
                                        ./home.nix
                        ];
                };


                nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
                        inherit system;
                        modules = [
                                ./configuration.nix
                                {
                                        environment.systemPackages = [ vice ];
                                        services.udev.packages    = [ vice ];

                                        nixpkgs.overlays = [
                                                inputs.extest.overlays.default
                                        ];
                                }
                        ];
                };
        };
}
