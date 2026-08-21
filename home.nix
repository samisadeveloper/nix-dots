{...}: {
        imports = [
                ./apps/nvim.nix
        ];

        targets.genericLinux.enable = true;
        home.username = "sam";
        home.stateVersion = "24.05";
        home.homeDirectory = "/home/sam";
}
