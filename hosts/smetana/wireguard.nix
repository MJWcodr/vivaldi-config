{ pkgs, config, ... }: {
  networking.nat.enable = true;
  networking.nat.externalInterface = "eth0";
  networking.nat.internalInterfaces = [ "wg0" ];
  networking.firewall = { allowedUDPPorts = [ 51820 ]; };

  # Setup Public-Private key pair
  systemd.services.wireguard-keygen = {
    enable = true;
    after = [ "network.target" ];
		before = [ "networking.wireguard" ];
    path = [ pkgs.bash pkgs.wireguard-tools ];
    script =
      "	mkdir -p /etc/wireguard-keys\n	\n	# check if private key exists\n	if [ -f /etc/wireguard-keys/private ]; then\n		exit 0\n	fi\n\n	wg genkey > /etc/wireguard-keys/private\n	wg pubkey < /etc/wireguard-keys/private > /etc/wireguard-keys/public\n";

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # Enable the WireGuard server
  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.1/24" ];

      # The port that WireGuard listens to. Must be accessible by the client.
      listenPort = 51820;

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      '';

      # This undoes the above command
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      '';

      # Path to the private key file.
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = "/etc/wireguard-keys/private";
      # generatePrivateKeyFile = true;

      peers = [
        {
          publicKey = "hXwMNTi8MInGh7VHf6yLh/xeC1LuZFZlSxFWOtz3Byw=";
          allowedIPs = [ "10.100.0.2/32" ]; # Vivaldi
        }
        {
          publicKey = "6nyO29otawA+T8IwmasPz9kEPX2TAKPcHpmszRLLTCM=";
          allowedIPs = [ "10.100.0.3/32" ]; # MJW-Laptop
        }
        {
          publicKey = "22FCDiSTGlr8o1sb9mhnOzb8pbQzk7KvYVF25fTt5As=";
          allowedIPs = [ "10.100.0.4/32" ]; # Pixel 6a
        }
        {
          publicKey = "tZkkw3chA9mMWOjmC8xrhmL+6SUtK0VQwdggtjnwVzc=";
          allowedIPs = [ "10.100.0.10/32" ]; # Papa's Raspberry Pi
        }
      ];
    };
  };

}
