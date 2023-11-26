{pkgs, config, ...}:
let
	internalPort = 8999;
	exposedPort = 9000;
	domain = "vivaldi.fritz.box";
in 
{


	##########
	# Secrets
	##########
	age.secrets.paperless = {
		file = ../secrets/paperless.age;
		owner = config.services.paperless.user;
	};

	# Create Data Directory
	system.activationScripts.paperless = ''
		mkdir -p /var/lib/paperless/media
		chown -R ${config.services.paperless.user} /var/lib/paperless

		mkdir -p /srv/documents
		chown -R ${config.services.paperless.user} /srv/documents
	'';

	services.paperless = {
		enable = true;
		package = pkgs.paperless-ngx;
		address = "localhost";
		mediaDir = "/srv/documents";
		dataDir = "/var/lib/paperless";
		port = internalPort;
		passwordFile = config.age.secrets.paperless.path;
		extraConfig = {
			PAPERLESS_OCR_LANGUAGE = "deu+eng";
			PAPERLESS_URL = "https://${domain}:${toString exposedPort}";
			PAPERLESS_ADMIN_USER = "mjwcodr";
		};
	};

	services.nginx.virtualHosts."paperless" = {
		forceSSL = true;
		sslCertificate = config.age.secrets.sslcert.path;
		sslCertificateKey = config.age.secrets.sslkey.path;
		locations."/" = {
			root = "/var/lib/paperless/media";
			proxyPass = "http://localhost:${toString internalPort}";
		};
		listen = [ 
			{
				ssl = true;
				addr = domain;
				port = exposedPort; 
			} 
			];
	};

	networking.firewall.allowedTCPPorts = [ exposedPort ];
}
