{config, pkgs, ...}:
let
	internalPort = 5231;
	externalPort = 5232;
in
{

	# Secrets
	age.secrets."secrets/radicale-auth.age" = {
		file = ../secrets/radicale-auth.age;
		owner = "radicale";
	}; 
	
	# Radicale
	services.radicale = {
		enable = true;
		package = pkgs.radicale;
		settings = {
			server = {
				hosts = [ "0.0.0.0:${toString internalPort}" "[::]:${toString internalPort}" ];
			};

			auth = {
				type = "htpasswd";
				htpasswd_encryption = "bcrypt";
				htpasswd_filename = "${config.age.secrets."secrets/radicale-auth.age".path}";
			};
		};
	};

	# Nginx
	services.nginx.virtualHosts."radicale" = {
		locations."/" = {
			proxyPass = "http://localhost:${toString internalPort}";
		};

		listen = [ {
			ssl = false;
			port = externalPort;
			addr = "vivaldi.fritz.box";
		} ];

	};

	networking.firewall.allowedTCPPorts = [ externalPort ];
}
