{ config, pkgs, ... }:
let
  APIinternalPort = 3455;
  APIexternalPort = 3456;
  frontendinternalPort = 3457;
  domain = "vivaldi.fritz.box";
	dir = "/var/lib/vikunja";
in {


	##############
	# Directories and Users Setup
	##############
	system.activationScripts.vikunja = ''
		mkdir -p ${dir}/{files,db}
		chmod 777 ${dir}/{files,db}
	'';

	users.users.vikunja = {
		name = "vikunja";
		isSystemUser = true;
		group = "vikunja";
		extraGroups = [ "podman" ];
	};
	users.groups.vikunja = {};

  ##############
  # Vikunja - API
  ##############
	virtualisation.oci-containers.containers.vikunja-api = {
		image = "vikunja/api:latest";
		ports = [ "${toString APIinternalPort}:3456" ];
		volumes = [
			"${dir}/files:/app/vikunja/files"
			"${dir}/db:/app/vikunja/db"
		];
		# user = "vikunja";
		environment = {
			VIKUNJA_DATABASE_HOST = "localhost";
			VIKUNJA_DATABASE_TYPE = "sqlite";
			VIKUNJA_DATABASE_PATH = "/app/vikunja/db/vikunja.db";
			VIKUNJA_FRONTEND_URL = "https://${domain}:${toString APIexternalPort}";
			VIKUNJA_SERVICE_ENABLEREGISTRATION = "true";

		};
	};

  ##############
  # Vikunja - Frontend
  ##############

  virtualisation.oci-containers.containers.vikunja-frontend = {
    image = "vikunja/frontend:latest";
    ports = [ "${toString frontendinternalPort}:80" ];
  };

  ##############
  # Database
  ##############

  ##############
  # Nginx
  ##############
  services.nginx = {
    virtualHosts = {
      "vikunja" = {
        locations."/" = {
          proxyPass = "http://localhost:${toString frontendinternalPort}";
        };
				locations = {
					"~* ^/(api|dav|\.well-known)/" = {
						proxyPass = "http://localhost:${toString APIinternalPort}";
					};
				};
        listen = [{
          ssl = true;
          port = APIexternalPort;
          addr = domain;
        }];

        forceSSL = true;
        sslCertificate = config.age.secrets.sslcert.path;
        sslCertificateKey = config.age.secrets.sslkey.path;
      };

    };
  };
  networking.firewall.allowedTCPPorts =
    [ APIexternalPort ];
}
