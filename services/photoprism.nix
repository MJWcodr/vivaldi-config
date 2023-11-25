{pkgs, config, ...}:
let
	internalPort = 2341;
	exposedPort = 2352;
	domain = "vivaldi.fritz.box";
in
{

	############
	# Secrets
	############
	
	age.secrets = {
		photoprismAdminPassword = {
			file = ../secrets/photoprism.age;
			owner = "photoprism";
			group = "photoprism";
		};
	};

	users.users.photoprism = {
		group = "photoprism";
		isSystemUser = true;
	 
	};

	users.groups.photoprism = {};
	
	############
  # Photoprism
	############
	
	systemd.services.photoprism-pre = {
		description = "Photoprism pre-startup";
		after = [ "network.target" ];
		wants = [ "network.target" ];
		before = [ "photoprism.service" ];
		path = [ pkgs.coreutils pkgs.bash pkgs.openssl pkgs.gnused ];
		
		serviceConfig.Type = "oneshot";

		script = ''
		#!/bin/sh
		# This script is executed before Photoprism starts.
		
		mkdir -p /run/photoprism
		chown -R photoprism:photoprism /srv/photos

		'';
	};

	systemd.timers.photoprism-import = {
		description = "Photoprism import";
		timerConfig.OnCalendar = "hourly";
		timerConfig.Unit = "photoprism-import.service";
	};

	systemd.services.photoprism-import = {
		description = "Photoprism import";
		after = [ "photoprism-pre.service" ];
		wants = [ "photoprism-pre.service" ];
		path = [ pkgs.coreutils pkgs.bash pkgs.openssl pkgs.gnused pkgs.photoprism ];
		
		serviceConfig.Type = "simple";

		script = ''
		# Import photos
		photoprism --originals-path /srv/photos/ --import-path /var/lib/photoprism/import import

		'';
	};

  services.photoprism = {
    enable = true;
    port = internalPort;
    originalsPath = "/srv/photos";
    address = "localhost";
    settings = {
      PHOTOPRISM_ADMIN_USER = "admin";
      PHOTOPRISM_ADMIN_PASSWORD = "admin";
      PHOTOPRISM_DEFAULT_LOCALE = "de";
      PHOTOPRISM_DATABASE_DRIVER = "mysql";
      PHOTOPRISM_DATABASE_NAME = "photoprism";
      PHOTOPRISM_DATABASE_SERVER = "/run/mysqld/mysqld.sock";
      PHOTOPRISM_DATABASE_USER = "photoprism";
      PHOTOPRISM_SITE_URL = "https://${domain}:${toString exposedPort}";
      PHOTOPRISM_SITE_TITLE = "My PhotoPrism";
			PHOTOPRISM_READONLY = "false";
			PHOTOPRISM_UPLOAD_NSFW = "true";
    };
		passwordFile = config.age.secrets.photoprismAdminPassword.path;
  };
	
	############
	# Database
	############

  services.mysql = {
    enable = true;
    # dataDir = "/data/mysql";
    package = pkgs.mariadb;
    ensureDatabases = [ "photoprism" ];
    ensureUsers = [ {
      name = "photoprism";
      ensurePermissions = {
        "photoprism.*" = "ALL PRIVILEGES";
      };
    } ];
  };

	############
	# Nginx
	############

  services.nginx = {
    enable = true;
       virtualHosts = {
      "photoprism" = {
				sslCertificate = "${config.age.secrets.sslcert.path}";
				sslCertificateKey = "${config.age.secrets.sslkey.path}";
        forceSSL = true;
        http2 = true;
        locations."/" = {
          proxyPass = "http://localhost:${toString internalPort}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $host;
            proxy_buffering off;
          '';
        };
				listen = [ {
					port = exposedPort;
					ssl = true;
					addr = "vivaldi.fritz.box";
				} ];
      };
    };
  };

	networking.firewall.allowedTCPPorts = [ exposedPort ];
}
