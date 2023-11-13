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
    domain = "viavldi.fritz.box";
    rootUrl = "http://vivaldi.fritz.box:3000/";
    httpPort = 3001;
		stateDir = "/srv/gitea";
  };
	
	networking.firewall.allowedTCPPorts = [ 3001 ];
}

