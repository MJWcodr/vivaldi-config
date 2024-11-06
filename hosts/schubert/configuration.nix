let
  sshPublicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiHRSsiYZ+pTA7L67XF6y1egdXhJOv09cjr4QhYiIPu";
in { pkgs, ... }: {
  imports = [
    # ./hardware-configuration.nix
    # ./networking.nix # generated at runtime by nixos-infect

    # Wireguard
    ./services/wireguard.nix

    # Nginx
    # ./nginx.nix

    # gitea
    # ./gitea-runner.nix

    # Home Assistant
    ./services/home-assistant.nix

    # podman
    # ./docker.nix

    # adguard
    # ./adguard.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  programs.mosh.enable = true;

  nix.settings.experimental-features = "nix-command flakes";

  # docker
  environment.systemPackages = with pkgs; [ vim git ];

  networking.domain = "schubert";
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
    passwordAuthentication = false;
  };
  users.users.root.openssh.authorizedKeys.keys = [ sshPublicKey ];

  networking = {
    hostName = "schubert";
    useDHCP = false;
    interfaces = {
      wlan.useDHCP = true;
      eth0.useDHCP = true;
    };
  };

  # create user matthias
  users.users.matthias = {
    isNormalUser = true;
    extraGroups = [ "wheel" "nix" "docker" ];
    openssh.authorizedKeys.keys = [ sshPublicKey ];
    hashedPassword =
      "$y$j9T$A23QXnn.XjIZCEjSnS1FH.$WDnkSFGM/Ry.wRsHWEW5Wjc14ZPFLWT4SHkbo9cAct9";
  };

  nix.allowedUsers = [ "matthias" "root" ];
  nix.settings = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
