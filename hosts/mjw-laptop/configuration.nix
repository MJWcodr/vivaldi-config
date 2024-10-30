# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, pkgs, config, ... }:
let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/master.tar.gz";
    sha256 = "sha256:0kg9iaixqygpncw7avgh1grwyjgnfc9i7k9pk8hc4xrvr8jv2l3c";
  };

in
{
  imports = [
    # Enable Home-Manager
    (import "${home-manager}/nixos")

    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # Enable Syncthing
    # ./hosts/mjw-laptop/services/syncthing.nix
    ./services/syncthing.nix

    # Include the wireguard configuration
    ./services/wireguard.nix

		# ../../modules/qobuz-downloader.nix
  ];

	programs.nix-ld.enable = true;

  home-manager.users.matthias = {
    # The home.stateVersion option does not have a default and must be set
    imports = [ ./home.nix ];
    # Here goes the rest of your home-manager config, e.g. home.packages = [ pkgs.foo ];

    dconf = {
      enable = true;
      settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
    };
  };

  # Get latest KERNEL
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "mjw-laptop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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

  # if you use pulseaudio
  nixpkgs.config.pulseaudio = true;

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager = {
      gnome.enable = true;
      # Windows 95
      # xterm.enable = false;
      # xfce.enable = true;
    };
  };

	services.displayManager.defaultSession = "gnome";

  boot.binfmt.registrations.appimage = {
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    recognitionType = "magic";
    offset = 0;
    mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
    magicOrExtension = ''\x7fELF....AI\x02'';
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

    		10.100.0.2 vivaldi-ext
    		10.100.0.1 gateway-ext

    		127.0.0.1 localhost
    		::1 localhost
  '';


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.matthias = {
    isNormalUser = true;
    description = "Matthias";
    extraGroups = [ "networkmanager" "wheel" "hidraw" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      firefox
      thunderbird
      vim
      git
      transmission_4
      transmission_4-gtk
			typst-lsp
			tinymist
			websocat
    ];
  };

  services.udev.packages = with pkgs; [ gnome-settings-daemon ];

  programs.fish.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "maltego"
  ];

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
    #  wget

    gnomeExtensions.task-widget # Task Widget for Gnome
    gnomeExtensions.appindicator
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

  ##########
  # Bluetooth
  ##########

  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
    };
  };

	##########
	# Qobuz Downloader
	##########

	# age.secrets = {
	#	qobuzConfig = {
	#		file = ../../secrets/qobuzConfig.age;
	#		owner = config.services.qobuz-downloader.user;
	#	};
	#};

	# services.qobuz-downloader = {
	#	enable = true;
	#	user = "matthias";
	#	configFilePath = config.age.secrets.qobuzConfig.path;
	#};

  ##########
  # Finger Print Reader
  ##########
  # Install the driver
  services.fprintd.enable = true;
  # If simply enabling fprintd is not enough, try enabling fprintd.tod...
  services.fprintd.tod.enable = true;
  # ...and use one of the next four drivers
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix; # Goodix driver module
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-elan # Elan(04f3:0c4b) driver
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-vfs0090; # driver for 2016 ThinkPads
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix-550a # Goodix 550a driver (from Lenovo)


  ##########
  # Hidraw
  ##########

  users.groups.hidraw = {
    gid = 1010;
  };

  services.udev.extraRules = ''
    		# https://unix.stackexchange.com/a/85459
    		# Allow all users to access hidraw devices
    		KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="hidraw"
    	'';

  ##########
  # Enable Experimental Features
  ##########

  nix.settings.experimental-features = "nix-command flakes";
	nix.settings.auto-optimise-store = true;
	nix.settings.trusted-users = [ "matthias" ];
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 5173 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
