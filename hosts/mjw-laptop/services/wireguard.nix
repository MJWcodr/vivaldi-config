{ pkgs, config, ... }:

{

  networking.firewall = { allowedUDPPorts = [ 51820 ]; };

  # Setup Public-Private key pair
  systemd.services.wireguard-keygen = {
    enable = true;
    after = [ "network.target" ];
    path = [ pkgs.bash pkgs.wireguard-tools ];
    script =
      "	mkdir -p /etc/wireguard-keys\n	\n	# check if private key exists\n	if [ -f /etc/wireguard-keys/private ]; then\n		exit 0\n	fi\n\n	wg genkey > /etc/wireguard-keys/private\n	wg pubkey < /etc/wireguard-keys/private > /etc/wireguard-keys/public\n";

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  networking.wireguard.interfaces = {
    wg0 = {
      # The IP address of the WireGuard interface.
      ips = [ "10.100.0.3/24" ];
      listenPort = 51820;

      # The private key of the peer.
      # generatePrivateKeyFile = true;

      privateKeyFile = "/etc/wireguard-keys/private";

      peers = [{
        # The public key of the peer.
        publicKey = "Y+pFXSFxKdHII4llp74CI9cTLIPos98ylGnktUPUaGA=";

        # Forward traffic to the peer.
        allowedIPs = [
          "10.100.0.0/24"
        ]; # 10.100.0.0/24 is the subnet of the wireguard network

        # The endpoint of the peer.
        endpoint = "gateway.mjwcodr.de:51820";

        # Send a keepalive packet every 25 seconds.
        persistentKeepalive = 25;
      }];
    };
  };

  # Setup Test Nginx Server
  services.nginx = {
    virtualHosts."mjwcodr.de" = {
      root = "/var/www/mjwcodr.de";
      listen = [{
        addr = "10.100.0.3";
        port = 80;
      }];
    };
  };
}
