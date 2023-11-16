{config, ...}:
{
	


	age.secrets = {
		"wireguard-server-publickey".file = ../secrets/wireguard-server-publickey.age;

		"wireguard-client-privatekey".file = ../secrets/wireguard-client-privatekey.age;
		"wireguard-client-publickey".file = ../secrets/wireguard-client-publickey.age;
	};
	# Setup Wireguard
	networking.nat.enable = true;
	networking.nat.externalInterface = "eth0";
	networking.nat.internalInterfaces = [ "wg0" ];
	networking.firewall = {
		allowedUDPPorts = [ 51820 ];
	};

	# Move the client's public key into the store
	# This is a bit of a hack, but it's the only way I could find to get the public key into the store
	environment.etc = {
		"wireguard/public.key".text = builtins.readFile config.age.secrets."wireguard-client-publickey".path;
	};

	networking.wireguard.interfaces.wg0 = {
		ips = [ "10.8.0.2/24" ];
		privateKeyFile = config.age.secrets."wireguard-client-privatekey".path;
		listenPort = 51820;

		peers = [
			{
				publicKey = "bGZaLqXjUM1QFpDuLzY2N2DA1c6W+uThbzqCFHMQDWU=";
				# builtins.readFile should normally be avoided, but in this case it's fine,
				# since we're reading a public key, which is not secret.
				allowedIPs = ["10.8.0.0/24"];
				endpoint = "203.0.113.1:51820";
				persistentKeepalive = 25;
			}
			];
		}; 
	#TODO: Remove this
	# test service for the new wireguard ip
	services.nginx = {
		enable = true;
		virtualHosts."Wireguard-test" = {
			listen = [ 
			{ 
				port = 80; 
				addr = "10.8.0.2";
			} 
			];
			};
		};

		
}
