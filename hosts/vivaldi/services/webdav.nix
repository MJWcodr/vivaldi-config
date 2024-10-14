{ config, ... }:
let
	port = 9100;
	sslPort = 9110;
in
{
	imports = [
		../../../modules/webdav.nix
	];

	services.webdavShare = {
		addr = "vivaldi.fritz.box";
		enable = true;
		serveDir = "/srv/data";
		port = port;
		htpasswdFile = ./webdav/htpasswd;
	};

	services.nginx.virtualHosts = {
		"webdavShare" = {
			forceSSL = true;
			sslCertificate = config.age.secrets.sslcert.path;
			sslCertificateKey = config.age.secrets.sslkey.path;
			locations."/" = {
				proxyPass = "http://localhost:9100";
				extraConfig = ''
				client_max_body_size 0;
				'';
			};
			listen = [
				{
					port = sslPort;
					ssl = true;
					addr = config.services.webdavShare.addr;
				}
			];
		};
	};

	networking.firewall.allowedTCPPorts = [ port sslPort ];
}
