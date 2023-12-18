{config, pkgs, ...}:

let
	internalPort = 8095;
	exposedPort = 8096;
	domain = "vivaldi.fritz.box";
in
{

	system.activationScripts.jellyfin = ''
		mkdir -p /srv/jellyfin/{cache,log,config}
		mkdir -p /srv/entertainment/{movies,tv,youtube}

	'';

	# Jellyfin
  virtualisation.oci-containers.containers."jellyfin" = {
    autoStart = true;
    image = "jellyfin/jellyfin";
    volumes = [
      "/srv/jellyfin/config:/config" # TODO: set this to read-only
      "/srv/jellyfin/cache:/cache"
      "/srv/jellyfin/log:/log"
      "/srv/entertainment/movies:/movies"
      "/srv/entertainment/tv:/tv"
			"/srv/entertainment/youtube:/youtube"

			# Hardware passthrough
			"/dev/dri:/dev/dri"
    ];
    ports = [ 
			"8095:8096" 
			"8919:8920"
			];
    environment = {
      JELLYFIN_LOG_DIR = "/log";
    };
  };

	services.nginx.virtualHosts."jellyfin-http" = {
		sslCertificate = config.age.secrets.sslcert.path;
		sslCertificateKey = config.age.secrets.sslkey.path;
		locations."/" = {
			proxyPass = "http://localhost:8095";
		};
		forceSSL = false;
		listen = [ {
			ssl = false;
			port = 8096;
			addr = domain;
		} ];
	};

	services.nginx.virtualHosts."jellyfin-https" = {
		sslCertificate = config.age.secrets.sslcert.path;
		sslCertificateKey = config.age.secrets.sslkey.path;
		locations."/" = {
			proxyPass = "http://localhost:8919";
		};
		forceSSL = true;
		listen = [ {
			ssl = true;
			port = 8920;
			addr = domain;
		} ];
	};

	networking.firewall.allowedTCPPorts = [ 8096 8920 ];
}
