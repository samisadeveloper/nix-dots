{pkgs, inputs, ...}:
let
        # this script syncs calestia schemes with the hyprland border color
        # possibly move this to a .sh file?
        # builtints.readFile ./path/to/file.sh
        sync-script = (pkgs.writeShellScriptBin "caelestia-hypr-sync" ''
                FILE="$HOME/.local/state/caelestia/scheme.json"

                DIR="$HOME/.local/state/caelestia"
                TARGET="scheme.json"

                apply_theme() {
                        echo applying theme!

                        if [ -f "$FILE" ]; then
                                # Extract variables (assuming 'primary' and 'secondary' are your JSON keys)
                                # Fallback hex codes are provided just in case jq fails

                                PRIMARY=$(jq -r '.colours.primary // "6568a3"' "$FILE")
                                SECONDARY=$(jq -r '.colours.secondary // "7365a3"' "$FILE")

                                echo $PRIMARY
                                echo $SECONDARY

                                hyprctl eval "hl.config({general = {['col.active_border'] = {['colors'] = {'#"$PRIMARY"', '#"$SECONDARY"'}}}})"
                        fi
                }

                apply_theme # apply immediately

                inotifywait -q -m -e close_write,moved_to "$DIR" | while read -r directory events filename; do
                        if [ "$filename" = "$TARGET" ]; then
                                apply_theme
                        fi
                done
        '');

        inherit (pkgs) lib;
in {
        imports = [
                inputs.caelestia-shell.homeManagerModules.default
        ];

        # any dependencies
        home.packages = with pkgs; [
                hyprshutdown
                jq
                inotify-tools
                sync-script
                quickshell
                playerctl
        ];

        xdg.configFile."quickshell/overview" = {
                source = "${inputs.quickshell-overview}/";
        };

        programs.caelestia = {
                enable = true;

                systemd = {
                        enable = false; # if you prefer starting from your compositor
                        target = "graphical-session.target";
                        environment = [];
                };
                settings = {
                        general.idle = {
                                lockBeforeSleep = false;
                                inhibitWhenAudio = false;
                                timeouts = [];
                        };

                        bar.statusIcons = [
                                { id = "lockStatus"; enabled = false; }
                                { id = "network"; enabled = true; }
                                { id = "bluetooth"; enabled = true; }
                                { id = "battery"; enabled = false; }
                        ];

                        paths.wallpaperDir = "~/Videos/Wallpapers/";
                };
                cli = {
                        enable = true; # Also add caelestia-cli to path
                                settings = {
                                        theme.enableGtk = false;
                                };
                };
        };

        wayland.windowManager.hyprland.enable = true;

        wayland.windowManager.hyprland.settings =
        {
                mod = {
                        _var = "SUPER";
                };

                config = {
                        general = {
                                gaps_in = 5;
                                gaps_out = 15;
                                border_size = 2;
                        };

                        misc = {
                                disable_hyprland_logo = true;
                                force_default_wallpaper = 0;
                                disable_splash_rendering = true;
                        };

                        decoration = {
                                rounding = 5;
                        };
                };

                # TODO: different monitor setup for different devices
                monitor = [
                        {
                                output = "DP-2";
                                position = "0x0";
                                scale = 1;
                                mode = "2560x1440@180";
                        }
                        {
                                output = "DP-1";
                                position = "2560x0";
                                scale = 1;
                                mode = "2560x1440@180";

                        }
                ];

                # open quickshell overview
                bind = [
                {
                        _args = [
                                "SUPER + TAB"
                                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"qs ipc -c overview call overview toggle\")")
                        ];
                }

                # keybind for gpu screen recorder
                {
                        _args = [
                                "ALT + Z"
                                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"gsr-ui-cli toggle-show\")")
                        ];
                }

                # closing apps
                {
                        _args = [
                                (lib.generators.mkLuaInline "mod .. \" + Q\"")
                                        (lib.generators.mkLuaInline "hl.dsp.window.close()")
                                        { locked = true; }
                        ];
                }

                # open kitty
                {
                        _args = [
                                "SUPER + RETURN"
                                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"kitty\")")
                        ];
                }

                # open the menu
                {
                        _args = [
                                "SUPER + D"
                                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"caelestia shell drawers toggle launcher\")") # this seems to be more reliable
                        ];
                }

                # fullscreen
                {
                        _args = [
                                "SUPER + F"
                                (lib.generators.mkLuaInline "hl.dsp.window.fullscreen()")
                        ];
                }

                # set floating
                {
                        _args = [
                                "SUPER + V"
                                        (lib.generators.mkLuaInline "hl.dsp.window.float()")
                        ];
                }


                # take screenshot
                {
                        _args = [
                                "SUPER + SHIFT + S"
                                (lib.generators.mkLuaInline "hl.dsp.global(\"caelestia:screenshot\")")
                        ];
                }

                # --- MULTI MEDIA ---

                # volume up
                {
                        _args = [
                                "XF86AudioRaiseVolume"
                                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+\")")
                        ];
                }

                # volume down
                {
                        _args = [
                                "XF86AudioLowerVolume"
                                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-\")")
                        ];
                }

                # volume mute/unmute
                {
                        _args = [
                                "XF86AudioMute"
                                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle\")")
                        ];
                }

                # play/pause
                {
                        _args = [
                                "XF86AudioPlay"
                                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl play-pause\")")
                        ];
                }

                # audio next
                {
                        _args = [
                                "XF86AudioNext"
                                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl next\")")
                        ];
                }

                # audio previous
                {
                        _args = [
                                "XF86AudioPrev"
                                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl previous\")")
                        ];
                }


                # --- KEYBOARD MOVEMENTS (vim style) ---

                ]
                ++ (
                        let
                                # lib = nixpkgs.lib;
                                directions = [
                                        { bind = "L"; direction = "r"; }
                                        { bind = "H"; direction = "l"; }
                                        { bind = "K"; direction = "u"; }
                                        { bind = "J"; direction = "d"; }
                                ];
                        in
                                lib.concatMap (direction: [
                                        {
                                                _args = [
                                                        "SUPER + ${direction.bind}"
                                                        (lib.generators.mkLuaInline "hl.dsp.focus({direction = \"${direction.direction}\"})")
                                                ];
                                        }
                                        {
                                                _args = [
                                                        "SUPER + SHIFT + ${direction.bind}"
                                                        (lib.generators.mkLuaInline "hl.dsp.window.move({direction = \"${direction.direction}\"})")
                                                ];
                                        }
                                ]) directions
                )
                ++ [

                # --- MOUSE MOVEMENTS ---

                # dragging
                {
                        _args = [
                                "SUPER + mouse:272"
                                (lib.generators.mkLuaInline "hl.dsp.window.drag()")
                                (lib.generators.mkLuaInline "{mouse = true}")
                        ];
                }

                #resizing
                {
                        _args = [
                                "SUPER + mouse:273"
                                (lib.generators.mkLuaInline "hl.dsp.window.resize()")
                                (lib.generators.mkLuaInline "{mouse = true}")
                        ];
                }

                # --- session management ---

                # lock the session
                {
                        _args = [
                                "SUPER + ALT + L"
                                (lib.generators.mkLuaInline "hl.dsp.global(\"caelestia:lock\")")
                        ];
                }

                # manage session
                {
                        _args = [
                                "SUPER + SHIFT + E"
                                (lib.generators.mkLuaInline "hl.dsp.global(\"caelestia:session\")")
                        ];
                }

                ]
                ++ (
                        builtins.concatLists (builtins.genList (i:
                                 [
                                        {
                                                _args = [
                                                        "SUPER + ${toString i}"
                                                        (lib.generators.mkLuaInline "hl.dsp.focus({workspace = ${toString i}})")
                                                ];
                                        }

                                        {
                                                _args = [
                                                        "SUPER + SHIFT + ${toString i}"
                                                        (lib.generators.mkLuaInline "hl.dsp.window.move({workspace = ${toString i}})")
                                                ];
                                        }

                                ]
                        )
                        10)
                );

                on = {
                        _args = [
                                "hyprland.start"
                                        (lib.generators.mkLuaInline
                                                "function()
                                                hl.exec_cmd(\"caelestia-shell\")
                                                hl.exec_cmd(\"hyprpaper\")
                                                hl.exec_cmd(\"caelestia-hypr-sync\")
                                                hl.exec_cmd(\"qs -p ~/.config/quickshell/overview\")
                                                end"
                                        )
                        ];
                };
        };
}
