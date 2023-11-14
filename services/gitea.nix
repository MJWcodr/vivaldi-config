{ config, ... }:
{

	age.secrets."secrets/postgrespass.age" = {
		file = ../secrets/postgrespass.age;
		owner = config.services.gitea.user;
	};
	services.nginx.virtualHosts."vivaldi.fritz.box" = {
    enableACME = false;
    forceSSL = false;
    locations."/" = {
      proxyPass = "http://localhost:3001/";
    };
  };

  services.postgresql = {
    ensureDatabases = [ config.services.gitea.user ];
    ensureUsers = [
      {
        name = config.services.gitea.database.user;
        ensurePermissions."DATABASE ${config.services.gitea.database.name}" = "ALL PRIVILEGES";
      }
    ];
  };

	system.activationScripts.gitea = {
		text = ''
			#!/bin/sh
			set -e
			mkdir -p /srv/gitea
			chown -R ${config.services.gitea.user}:${config.services.gitea.group} /srv/gitea
		'';
	};

  services.gitea = {
    enable = true;
    appName = "My awesome Gitea server"; # Give the site a name
    database = {
      type = "postgres";
      passwordFile = config.age.secrets."secrets/postgrespass.age".path;
			};
		stateDir = "/srv/gitea";
		settings.server = {
			DOMAIN = "vivaldi.fritz.box";
			ROOT_URL = "http://vivaldi.fritz.box:3001/";
			HTTP_PORT = 3001;
		};
  };
	
	networking.firewall.allowedTCPPorts = [ 3001 ];
}

