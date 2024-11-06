let
  sshPublicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOiHRSsiYZ+pTA7L67XF6y1egdXhJOv09cjr4QhYiIPu";
  sshPublicKeyJuri =
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDnT2o2CaShcjpniWJHnRMjX0rvxlfIv6PMUcFx3QnPCSzcEKzzKLMXlpuchduzTPFwKTM/x9KF5FjRz5NscbURDd5HTsnxtU/pyGv2fcvx2F5T3C4PufYwvQ73Y+gJZ7ANkoqWDQb/50T9LkLlSRB7BOgd1TgA+826J7DZOFdbkNCGh9VsuOWxTnIiOcMI85v9Ro2MXXg/0DH+5KvqEqBUPAIqttqbFEt8wwtwkOnFKuMDPP3Kk/1GFVUfxOdQCUC7vBtWbolFakdeyXzUEg1LyC+SXKk5iJ/FJ0SSyvqCQ4usDTFXTK3Tlb4/kriufX+YG8Owa4YXucJW1ObhAYZIo23SIsh1u7DyYPKEV9kDlPl5HcRucNTEyIAKaihu5/f3wAPSgrcWdj9uaThZAopoWzL3WsK9bZXmAi5Ft6plExfPtMnbne84nUT7yGyGPnZa3P/1QNaLyTlhSPosPbC8h6v+6irIk+Lry8YxHxBkxjaNggKrB/M9jpebmYaW7is= jmein@JuriLaptop";
in { pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect

    # Wireguard
    ./wireguard.nix

    # Nginx
    ./nginx.nix

    # gitea
    ./gitea-runner.nix

    # podman
    ./docker.nix

    # adguard

    # ./adguard.nix

		# home assistant on other host
		./ahrensfelde.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  programs.mosh.enable = true;

  networking.hostName = "vpn-gateway";

  nix.settings.experimental-features = "nix-command flakes";

  # docker
  environment.systemPackages = with pkgs; [ docker ];

  networking.domain = "gateway.mjwcodr.de";
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
    passwordAuthentication = false;
  };
  users.users.root.openssh.authorizedKeys.keys = [ sshPublicKey ];

  # create user matthias
  users.users.matthias = {
    isNormalUser = true;
    extraGroups = [ "wheel" "nix" "docker" ];
    openssh.authorizedKeys.keys = [ sshPublicKey ];
    hashedPassword =
      "$y$j9T$A23QXnn.XjIZCEjSnS1FH.$WDnkSFGM/Ry.wRsHWEW5Wjc14ZPFLWT4SHkbo9cAct9";
  };

  nix.allowedUsers = [ "matthias" "root" ];
}
