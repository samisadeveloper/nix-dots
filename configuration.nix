# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # setup ntfs filesystem
  boot.supportedFilesystems = [ "ntfs" ];
  
  # TODO: refactor

  # mount games
  fileSystems."/mnt/games" =
  { device = "/dev/disk/by-uuid/01DAC42651A1A3C0";
          fsType = "ntfs";
          options = [ "rw" "uid=1000" "gid=100" "umask=0022" "nofail" ];
  };

  # mount data
  fileSystems."/mnt/data" =
  { device = "/dev/disk/by-uuid/62E7E4144F9C3B7D";
          fsType = "ntfs";
          options = [ "rw" "uid=1000" "gid=100" "umask=0022" "nofail" ];
  };

  # mount windows
  fileSystems."/mnt/windows" =
  { device = "/dev/disk/by-uuid/AB131906BBB50449";
          fsType = "ntfs";
          options = [ "rw" "uid=1000" "gid=100" "umask=0022" "nofail" ];
  };

  # mount media
  fileSystems."/mnt/media" =
  { device = "/dev/disk/by-uuid/8FD1A8E5977326DD";
          fsType = "ntfs";
          options = [ "rw" "uid=1000" "gid=100" "umask=0022" "nofail" ];
  };

  # mount nextcloud
  systemd.services.rclone-nextcloud = {
          description = "Rclone mount for Nextcloud";
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ];
          path = [ "/run/wrappers" ];
          serviceConfig = {
                  Type = "notify";
                  ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /mnt/nextcloud";
                  ExecStart = "${pkgs.rclone}/bin/rclone mount nextcloud: /mnt/nextcloud --vfs-cache-mode writes --dir-cache-time 30s --config=/home/sam/.config/rclone/rclone.conf --uid=1000 --gid=100";
                  ExecStop = "${pkgs.fuse}/bin/fusermount -u /mnt/nextcloud";
                  Restart = "on-failure";
                  RestartSec = 5;
                  User = "sam";
          };
  };

# mount dell-depression-box
  fileSystems."/mnt/dell-server" = {
          device = "sam@192.168.0.201:/";
          fsType = "fuse.sshfs";
          options = [
# Standard systemd automount behaviors
                  "x-systemd.automount"
                          "noauto"
                          "allow_other"
                          "reconnect"
                          "ServerAliveInterval=15"
                          "ServerAliveCountMax=3"

# Points cleanly to the root-owned copy of your working key
                          "IdentityFile=/root/.ssh/id_ed25519"

# CRITICAL: Bypasses the hidden interactive "trust host" prompt that kills automounts
                          "StrictHostKeyChecking=no"

# Tell the systemd mount environment where to find the SSH binary inside NixOS
                          "ssh_command=${pkgs.openssh}/bin/ssh"
          ];
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable the Docker daemon
  virtualisation.docker.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # enable ollama for LLMS
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    environmentVariables = {
      HSA_OVERRIDE_GFX_VERSION = "10.3.0";
    };
  };

  # Enable flatpak for sober
  services.flatpak.enable = true;

  # Enable udiskie for USBs
  services.udisks2.enable = true;

  # Enable tailscale
  services.tailscale = {
    # Enable tailscale at startup
    enable = true;

    # If you would like to use a preauthorized key, set
    # authKeyFile = "/run/secrets/tailscale_key";
    # Note: maximum expire time is 90 days
  };

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = false;

  # Enable LY Display Manager
  services.displayManager.ly.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = true;

  # Enable the Hyprland Desktop Environment
  programs.hyprland.enable = true; # enable Hyprland

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sam = {
    isNormalUser = true;
    description = "sam";
    extraGroups = [ "networkmanager" "wheel" "docker" "render" "video" ];
  };

    # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes"];

  # steam moment
  programs.steam = {
        enable = true;
        extest.enable = true;
  };

  # coding or something
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
          mesa
          libxkbcommon
          glib
          nss
          nspr
          atk
          cups
          dbus
          libdrm
          gtk3
          pango
          cairo
          xorg.libX11
          xorg.libXcomposite
          xorg.libXdamage
          xorg.libXext
          xorg.libXfixes
          xorg.libXrandr
          mesa
          alsa-lib
          expat
  ];

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  programs.gpu-screen-recorder.enable = true;

  environment.systemPackages = with pkgs; [
        # --- mounting ---
        rclone

        # --- tools ---
        home-manager # nix home manager
        git # version control
        zoxide # good
        starship # bash
        xwayland-satellite
        yt-dlp

        # --- media ---
        vesktop # discord
        brave # browser
        obsidian # notes
        gimp # photo editing
        obs-studio # recording
        gpu-screen-recorder-ui # recording
        vlc # media player
  
        # --- gaming ---
        prismlauncher # minecraft launcher
        pcsx2 # PS2 Emulator
        rpcs3 # PS3 Emulator
        cemu # wii u emulator
        ryubing # switch emulator
        r2modman # mod manager
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
