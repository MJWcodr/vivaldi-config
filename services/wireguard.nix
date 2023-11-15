{config, ...}:
{
	
	age.secrets = {
		"wireguard-publickey".file = ../secrets/wireguard-publickey.age;
		"wireguard-privatekey".file = ../secrets/wireguard-privatekey.age;
	};

	# Setup Wireguard
	networking.nat.enable = true;
	networking.nat.externalInterface = "eth0";
	networking.nat.internalInterfaces = [ "wg0" ];
	networking.firewall = {
		allowedUDPPorts = [ 51820 ];
	};
	

	networking.wireguard.interfaces.wg0 = {
		ips = [ "10.8.0.2/24" ];
		privateKeyFile = config.age.secrets."wireguard-privatekey".path;
		listenPort = 51820;

		peers = [
			{
				publicKey = config.age.secrets."wireguard-publickey".path;
				allowedIPs = ["10.8.0.0/24"];

				endpoint = "203.0.113.1:51820";

				persistentKeepalive = 25;
			}
			];
		};

	
}
