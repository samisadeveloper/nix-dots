{pkgs, ...}: {
        home.packages = with pkgs; [
                # --- dependencies ---
                lazygit # nvim dependency
                nixd # nix LSP
                ripgrep # grep search
                fd # fdfind

                # --- apps ---
                yazi # file manager
        ];

        programs.nvf = {
                enable = true;
                settings = {
                        vim.opts.cursorline = true;

                        # fix any filetypes that aren't exact
                        vim.filetype.extension = { xaml = "xml"; };

                        vim.terminal.toggleterm.enable = true;
                        vim.terminal.toggleterm.lazygit.enable = true;
                        vim.binds.whichKey.enable = true;

                        # lsp
                        vim.lsp.enable = true;

                        vim.languages.tsx.enable = true;
                        vim.languages.typescript.enable = true;
                        vim.languages.java.enable = true;
                        vim.languages.docker.enable = true;

                        # C# installation
                        vim.languages.csharp.enable = true;
                        vim.languages.csharp.lsp.servers = ["csharp_ls"];
                        
                        # XML support
                        vim.languages.xml = {
                                enable = true;
                                lsp = {
                                        enable = true;
                                        servers = [ "lemminx" ];
                                };
                        };

                        vim.languages.nix = {
                                enable = true;
                                lsp.servers = [ "nixd" ];
                        };

                        # theme
                        vim.theme.enable = true;
                        vim.theme.name = "tokyonight";
                        vim.theme.style = "night";

                        # clipboard
                        vim.clipboard.enable = true;
                        vim.clipboard.providers.wl-copy.enable = true;
                        vim.clipboard.registers = "unnamedplus";

                        # project nvm
                        vim.projects.project-nvim.enable = true;

                        vim.projects.project-nvim.setupOpts.patterns = [ 
                                "pom.xml"
                                ".git"
                                "_darcs"
                                ".hg"
                                ".bzr"
                                ".svn"
                                "Makefile"
                                "package.json"
                                "flake.nix"
                                "cargo.toml"
                        ];

                        vim.projects.project-nvim.setupOpts.manual_mode = false;

                        # tools
                        vim.utility.yazi-nvim.enable = true;
                        vim.utility.motion.flash-nvim.enable = true;
                        vim.autocomplete.blink-cmp.enable = true;
                        vim.snippets.luasnip.enable = true;
                        vim.telescope.enable = true;
                        vim.telescope.mappings.buffers = "<leader><leader>";
                };
        };
}
