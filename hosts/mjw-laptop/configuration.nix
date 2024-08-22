# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, pkgs, ... }:
let
  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  agenix = builtins.fetchTarball
    "https://github.com/ryantm/agenix/archive/main.tar.gz";
in {
  imports = [
    # Enable Home-Manager
    (import "${home-manager}/nixos")

    # Add Catpuccin theme
    # Link to Guide: https://nix.catppuccin.com/getting-started/stable-nix.html
    <catppuccin/modules/nixos>

    # Include the agenix module
    "${agenix}/modules/age.nix"

    # Enable tracker for gnome
    ./services/tracker-fix.nix

		# Enable NVIDIA drivers
		# ./hosts/mjw-laptop/services/nvidia.nix

    # Include the results of the hardware scan.
    ./hosts/mjw-laptop/hardware-configuration.nix
		
    # Enable Syncthing
    ./hosts/mjw-laptop/services/syncthing.nix

    # Enable Hyprland
    ./dotfiles/hyprland.nix

    # Enable wireguard for Work VPN
    ./hosts/mjw-laptop/services/wireguard.nix

  ];

  home-manager.users.matthias = {
    # The home.stateVersion option does not have a default and must be set
    imports = [ ./hosts/mjw-laptop/home.nix ];
    # Here goes the rest of your home-manager config, e.g. home.packages = [ pkgs.foo ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
	boot.blacklistedKernelModules = [ "nouveau" "nvidiafb"];
  networking.hostName = "mjw-laptop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  programs.ssh.askPassword =
    "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";

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

  # if you use pulseaudio
  nixpkgs.config.pulseaudio = true;

	services.displayManager.defaultSession = "gnome";
	services.desktopManager.plasma6.enable = true;

  services.xserver = {
    enable = true;
    displayManager = {
      # sddm.enable = true;
      gdm.enable = true; # Gnome Display Manager
    };
    desktopManager = {
      gnome.enable = true;
      # Windows 95
      xterm.enable = false;
      # xfce.enable = true;
    };
  };

  boot.binfmt.registrations.appimage = {
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    recognitionType = "magic";
    offset = 0;
    mask = "\\xff\\xff\\xff\\xff\\x00\\x00\\x00\\x00\\xff\\xff\\xff";
    magicOrExtension = "\\x7fELF....AI\\x02";
  };

  # Configure keymap in X11
  services.xserver = {
    xkb = {
      variant = "";
      layout = "de";
    };
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  # sound.enable = true;
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

  networking.extraHosts = ''
  			0.0.0.0 www.youtube.com
  		 	::0 www.youtube.com
  			0.0.0.0 youtube.com
  			::0 youtube.com
  
				127.0.0.2 mjw-laptop
    		::2 mjw-laptop
    	
    		127.0.0.1 localhost
    		::1 localhost

				10.100.0.1 gateway
				10.100.0.2 vivaldi-ext
				192.168.178.10 vivaldi
  '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.matthias = {
    isNormalUser = true;
    description = "Matthias";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      vim
      git
      gnomeExtensions.task-widget # Task Widget for Gnome
    ];
  };

  programs.fish.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.autoUpgrade = {
    enable = true;
    dates = "02:00";
    randomizedDelaySec = "45min";
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    git

		( import ./dotfiles/bin/nvidia-offload.nix ) # nvidia-offload
    #  wget

    (pkgs.callPackage "${
        builtins.fetchTarball
        "https://github.com/ryantm/agenix/archive/main.tar.gz"
      }/pkgs/agenix.nix" { }) # agenix-cli

    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    # win-virtio # don't use windows
    # win-spice # don't use windows
  ];

  programs.virt-manager.enable = true;

  # Virtualisation
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;

  programs.nix-ld.enable = true;
	programs.steam = {
  enable = true;
  remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
};

  # Theme Gnome with Catppuccin
  catppuccin.enable = true;
  catppuccin.flavor = "mocha";
  catppuccin.accent = "peach";

  home-manager.backupFileExtension = "backup";

  nix.settings.experimental-features =
    [ "nix-command" "flakes" ]; # Enable Nix Flakes
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
		
	# 

	# Set up NextDNS

	 services.resolved = {
    enable = true;
    extraConfig = ''
    [Resolve]
		DNS=45.90.28.0#mjw-laptop-da57ae.dns.nextdns.io
		DNS=2a07:a8c0::#mjw-laptop-da57ae.dns.nextdns.io
		DNS=45.90.30.0#mjw-laptop-da57ae.dns.nextdns.io
		DNS=2a07:a8c1::#mjw-laptop-da57ae.dns.nextdns.io
		DNSOverTLS=yes
	'';
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
