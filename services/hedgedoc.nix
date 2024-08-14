{
	services.hedgedoc = {
		enable = true;
		settings = {
			port = 6699;
			# hostname = "127.0.0.1";
			domain = "doc.mjwcodr.de";
			allowOrigin = [
				"localhost"
				"vivaldi.fritz.box"
				"10.0.0.2"
				"doc.mjwcodr.de"
				"192.168.178.10"
			];
		};
	};

	services.nginx.virtualHosts."hedgedoc" = {
		locations."/" = {
			proxyPass = "http://localhost:6699";
		};
		listen = [
			{
				ssl = false;
				port = 6700;
				addr = "vivaldi.fritz.box";
			}
		];
	};

	networking.firewall.allowedTCPPorts = [ 6700 6699 ];
}
