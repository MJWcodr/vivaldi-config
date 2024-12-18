# Edit this configuration file to define what should be installed on

# your system.  Help is available in the configuration.nix(5) man page

# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, ... }:
let
  publicKey =
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCow7KnyMQO/WGYfyNAIVUf+KAK+Bk4OLxhwPrRjZom+KhADGjFvYn7dVzBh51/zPkd3BReuW8rpC6eyVDkX7rItOD9d32m2ozW/W5/h3UrSmpyo5DaqmPlXn9+TmLFENWWDXmqImRRlEb9Ts4md54d8cJVTF/Rolxi3y4dxALwnIKzPxorJ61rQEr04izdCo84c3NH+Q5fuu2NLgSJxnhLZTz+/DSexpmK7K9Mw23z73e1hRY68pi3/tQPQdVX0YGM2AHyubryrgbhEDzig6CAiHKEvWpc7hKeha/LYYiq9Rs/J1Nui1e/lcxLDz+lgNBMooiwvdrB3WIeVSjIVhx/wrT5YeYPKCWvPdPRZ5wZ3cPk76yB/I2AacHZEWqSXhS88wIdmuEcTAKDLP3HHUWYWpbY4JiaTFHtba4UpIkSd7wW5BY3HIupHLEwHMR7jemenak3ueQtsrCExeO3axD0VL4/xL/PgJPdZm8HsUsn+oJnz5cRBtv2a2gsmAcoPVc= matthias@Matthiass-MBP.fritz.box";
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/master.tar.gz";
    sha256 = "sha256:19w63qccz78v0spx03911z98w1bvlxvd07hb0ma14a4vdzi4ninj";
  };

in {
  imports = [
    # Include the results of the hardware scan.
    # Home Manager NixOS
    (import "${home-manager}/nixos")

    # Secret Management
    ./hardware-configuration.nix

    # Backup
    ./services/backup.nix

    # Photoprism
    ./services/photoprism.nix

    # Homer
    ./services/homer.nix

    # Syncthing
    ./services/syncthing.nix

    # Navidrome
    ./services/navidrome.nix

    # Gitea
    ./services/gitea.nix
    # /services/gitea/actions-runner.nix

    # ToDo - Vikunja
    ./services/vikunja.nix

    # Wireguard
    ./services/wireguard.nix

    # Reverse Proxy through Wireguard
    ./services/remote.nix

    # Grafana
    # ./services/grafana.nix

    # Workspace for Matthias
    # ../../workspace/workspace.nix
    # ./services/vnc.nix

    # Jellyfin
    ./services/jellyfin.nix

    # Paperless
    ./services/paperless.nix # Temporarily disabled

    # Home Assistant
    ./services/home-assistant.nix

    # Radicale
    ./services/radicale.nix

    # Tests
    ../../tests/nginx.nix

    # Mosh
    ./services/mosh.nix

    #./services/pi-hole.nix

    # Audiobookshelf
    ./services/audiobookshelf.nix

    # hedgedoc
    ./services/hedgedoc.nix

    ./services/webdav.nix

  ];

  home-manager.users.matthias = { imports = [ ./home.nix ]; };

  # PKI
  security.pki.certificateFiles = [ ./services/tls/ca.pem ];

  age.secrets = {
    sslcert = {
      file = ./../../secrets/sslcert.crt.age;
      owner = config.services.nginx.user;
    };
    sslkey = {
      file = ./../../secrets/sslcert.key.age;
      owner = config.services.nginx.user;
    };
  };

	age.secrets = {
    "secrets/sslcert.crt.age" = {
      file = ../../secrets/sslcert.crt.age;
      owner = config.services.nginx.user;
    };
    "secrets/sslcert.key.age" = {
      file = ../../secrets/sslcert.key.age;
      owner = config.services.nginx.user;
    };
  };

  system.autoUpgrade = {
    enable = true;
    # flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L" # print build logs
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.efi.canTouchEfiVariables = false;

  # It may be necessary to wait a bit for devices to be initialized.
  # See: https://github.com/NixOS/nixpkgs/issues/98741
  networking.hostName = "vivaldi"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  virtualisation.oci-containers.backend = "podman";
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  networking.firewall.trustedInterfaces = [ "podman0" ];

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable Fish
  programs.fish.enable = true;
  # Configure keymap in X11
  services.xserver = {
    layout = "de";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  # sound.enable = true; # obsolete
  hardware.pulseaudio.enable = false;
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
  users.users.matthias = {
    isNormalUser = true;
    description = "Matthias Wünsch";
    extraGroups = [ "networkmanager" "wheel" "nixoseditor" ];
    packages = with pkgs; [ firefox spotify home-manager bash htop ];
    openssh.authorizedKeys.keys = [ publicKey ];
    shell = pkgs.fish;
  };

  nix.settings.allowed-users = [ "matthias" ]; # Allow matthias to use nix

  users.users.miol = {
    isNormalUser = true;
    description = "Miol";
    extraGroups = [ "networkmanager" ];
    packages = with pkgs; [ spotify telegram-desktop ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    git
    # Nextcloud needs ffmpeg
    neovim
    ffmpeg
    nixfmt-rfc-style
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Dont autosuspend
  services.xserver.displayManager.gdm.autoSuspend = false;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.login1.suspend" ||
            action.id == "org.freedesktop.login1.suspend-multiple-sessions" ||
            action.id == "org.freedesktop.login1.hibernate" ||
            action.id == "org.freedesktop.login1.hibernate-multiple-sessions")
        {
            return polkit.Result.NO;
        }
    });
  '';

  # List services that you want to enable:
  environment.variables.EDITOR = "vim";
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 22 ];
  };

  services.logind.lidSwitch = "ignore";
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 80 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
