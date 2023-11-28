{ config, pkgs, ... }:
let
  APIinternalPort = 3455;
  APIexternalPort = 3456;
  frontendinternalPort = 3457;
  domain = "vivaldi.fritz.box";
	dir = "/var/lib/vikunja";
in {

	
	##############
	# Directories Setup
	##############
	system.activationScripts.vikunja = ''
		mkdir -p ${dir}/{files,db}
	'';

  ##############
  # Vikunja - API
  ##############
	virtualisation.oci-containers.containers.vikunja-api = {
		image = "vikunja/api:latest";
		ports = [ "${toString APIinternalPort}:3456" ];
		volumes = [
			"${dir}/files:/app/vikunja/files"
			"${dir}/db:/db"
		];
		
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
