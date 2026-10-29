{pkgs, ...}: {
        nixpkgs.config.allowUnfree = true;

        imports = [
                ./apps/spicetify.nix
                ./apps/nvim.nix
                ./apps/hyprland.nix
        ];

        fonts.fontconfig.enable = true;

        home.packages = with pkgs; [
                jetbrains-mono
        ];

        programs.direnv = {
                enable = true;
                nix-direnv.enable = true;
        };

        programs.kitty = {
                enable = true;

                extraConfig = ''
                        font_family family="JetBrainsMono Nerd Font"
                        font_size 12
                        background_opacity 0.35

                        cursor #b6dbe3
                        cursor_trail 3
                        cursor_trail_decay 0.1 0.2
                        cursor_shape block
                        cursor_blink_interval 0.8
                '';
        };

        targets.genericLinux.enable = true;
                
        home.username = "sam";
        home.stateVersion = "26.05";
        home.homeDirectory = "/home/sam";
}
