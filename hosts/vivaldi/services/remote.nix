{config, pkgs, ...}:
let
	# Photoprism
	photoprismPort = 2352;
	photoprismInternalPort = 2341;

	# Paperless
	paperlessPort = 9000;
	paperlessInternalPort = 8999;

	# Navidrome
	navidromePort = 4533;
	navidromeInternalPort = 8090;

	# Vikunja
	vikunjaPort = 3456;
	vikunjaAPIInternalPort = 3455;
	vikunjaFrontendInternalPort = 3457;

	# Notfications
	notificationsPort = 8500;
	notificationsInternalPort = 8499;

	# Jellyfin
	jellyfinPort = 8096;
	jellyfinInternalPort = 8095;

	# Home Assistant
	homeAssistantExternalPort = 8124;
	homeAssistantPort = 8123;

	radicalePort = 5232;
	radicaleInternalPort = 5231;

	freshRSSPort = 8090;
	freshRSSInternalPort = 8089;

	invidiousPort = 3040;
	invidiousInternalPort = 3039;

	audiobookshelfPort = 7000;
	audiobookshelfInternalPort = 6999;

	giteaPort = 3001;
	giteaInternalPort = 3000;

	hedgeDocPort = 6700;

	websitePort = 8000;

	domain = "mjwcodr.de";
	wireguardIP = "10.100.0.2";
in
{

	#################
	# Nginx
	#################

	services.nginx = {
		enable = true;
		virtualHosts = {
		# Website
		"${domain}" = {
			forceSSL = false;
			http2 = true;
			locations."/" = {
				proxyPass = "http://localhost:${toString websitePort}";
				proxyWebsockets = true;
				extraConfig = ''
					proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
					proxy_set_header Host $host;
					proxy_buffering off;
				'';
			};
			listen = [ {
				port = websitePort;
				ssl = false;
				addr = "${wireguardIP}";
			} ];
		};
		# Photoprism
			"photos.${domain}" = {				# SSL is terminated on the remote server
				forceSSL = false;
				http2 = true;
				locations."/" = {
					proxyPass = "http://localhost:${toString photoprismInternalPort}";
					proxyWebsockets = true;
					extraConfig = ''
						proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
						proxy_set_header Host $host;
						proxy_buffering off;
					'';
				};
				listen = [ {
					port = photoprismPort;
					ssl = false;
					addr = "${wireguardIP}";
				} ];
		};
		# Paperless
		"paper.${domain}" = {
			forceSSL = false;
			http2 = true;
			locations."/" = {
				proxyPass = "http://localhost:${toString paperlessInternalPort}";
				proxyWebsockets = true;
				extraConfig = ''
					proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
					proxy_set_header Host $host;
					proxy_buffering off;
				'';
			};
			listen = [ {
				port = paperlessPort;
				ssl = false;
				addr = "${wireguardIP}";
			} ];
		};
		# Vikunja
		"tasks.${domain}" = {
				locations = {
					"/" = {
						proxyPass = "http://localhost:${toString vikunjaFrontendInternalPort}";
					};
					"~* ^/(api|dav|\.well-known)/" = {
						proxyPass = "http://localhost:${toString vikunjaAPIInternalPort}";
					};
				};
        listen = [{
          ssl = false;
          port = 3500;
          addr = "10.100.0.2";
        }];
      };
		# Navidrome
		"music.${domain}" = {
			forceSSL = false;
			http2 = true;
			locations."/" = {
				proxyPass = "http://localhost:${toString navidromeInternalPort}";
				proxyWebsockets = true;
				extraConfig = ''
					proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
					proxy_set_header Host $host;
					proxy_buffering off;
				'';
			};
			listen = [ {
				port = navidromePort;
				ssl = false;
				addr = "${wireguardIP}";
			} ];
		};

		# Notifications
		"ntfy.${domain}" = {
			forceSSL = false;
			http2 = true;
			locations."/" = {
				proxyPass = "http://localhost:${toString notificationsInternalPort}";
				proxyWebsockets = true;
				extraConfig = ''
					proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
					proxy_set_header Host $host;
					proxy_buffering off;
				'';
			};
			listen = [ {
				port = notificationsPort;
				ssl = false;
				addr = "${wireguardIP}";
			} ];
		};

		# Jellyfin
		"movies.${domain}" = {
			forceSSL = false;
			http2 = true;
			locations."/" = {
				proxyPass = "http://localhost:${toString jellyfinInternalPort}";
				proxyWebsockets = true;
				extraConfig = ''
					proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
					proxy_set_header Host $host;
					proxy_buffering off;
				'';
			};
			listen = [ {
				port = jellyfinPort;
				ssl = false;
				addr = "${wireguardIP}";
			} ];
		};

		# Home Assistant
		"home.${domain}" = {
			forceSSL = false;
			http2 = true;
			locations."/" = {
				proxyPass = "http://localhost:${toString homeAssistantPort}";
				proxyWebsockets = true;
				extraConfig = ''
					proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
					proxy_set_header Host $host;
					proxy_buffering off;
				'';
			};
			listen = [ {
				port = homeAssistantExternalPort;
				ssl = false;
				addr = "${wireguardIP}";
			} ];
		};
		"calendar.${domain}" = {
			forceSSL = false;
			http2 = true;
			locations."/" = {
				proxyPass = "http://localhost:${toString radicaleInternalPort}";
				proxyWebsockets = true;
				extraConfig = ''
					proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
					proxy_set_header Host $host;
					proxy_buffering off;
				'';
			};
			listen = [ {
				port = radicalePort;
				ssl = false;
				addr = "${wireguardIP}";
			} ];
		};
		"rss.${domain}" = {
			forceSSL = false;
			http2 = true;
			locations."/" = {
				proxyPass = "http://localhost:${toString freshRSSInternalPort}";
				proxyWebsockets = true;
				extraConfig = ''
					proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
					proxy_set_header Host $host;
					proxy_buffering off;
				'';
			};
			listen = [ {
				port = freshRSSPort;
				ssl = false;
				addr = "${wireguardIP}";
			} ];
		};
		"yt.${domain}" = {
			forceSSL = false;
			http2 = true;
			locations."/" = {
				proxyPass = "http://localhost:${toString invidiousInternalPort}";
				proxyWebsockets = true;
				extraConfig = ''
					proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
					proxy_set_header Host $host;
					proxy_buffering off;
				'';
			};
			listen = [ {
				port = invidiousPort;
				ssl = false;
				addr = "${wireguardIP}";
			} ];
			};
		"audiobooks.${domain}" = {
			forceSSL = false;
			http2 = true;
			locations."/" = {
				proxyPass = "http://localhost:${toString audiobookshelfInternalPort}";
				proxyWebsockets = true;
				extraConfig = ''
					proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
					proxy_set_header Host $host;
					proxy_buffering off;
				'';
			};
			listen = [ {
				port = audiobookshelfPort;
				ssl = false;
				addr = "${wireguardIP}";
			} ];
		};
		"git.${domain}" = {
			forceSSL = false;
			http2 = true;
			locations."/" = {
				proxyPass = "http://localhost:${toString giteaInternalPort}";
				proxyWebsockets = true;
				extraConfig = ''
					client_max_body_size 512M;
        	proxy_set_header Connection $http_connection;
        	proxy_set_header Upgrade $http_upgrade;
        	proxy_set_header Host $host;
        	proxy_set_header X-Real-IP $remote_addr;
        	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        	proxy_set_header X-Forwarded-Proto $scheme;
				'';
			};

			listen = [ {
				port = giteaPort;
				ssl = false;
				addr = "${wireguardIP}";
			} ];
		};
		"doc.${domain}" = {
			forceSSL = false;
			http2 = true;
			locations."/" = {
				proxyPass = "http://localhost:${toString hedgeDocPort}";
				proxyWebsockets = true;
				extraConfig = ''
					proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
					proxy_set_header Host $host;
					proxy_buffering off;
				'';
			};
			listen = [ {
				port = 6700;
				ssl = false;
				addr = "${wireguardIP}";
			} ];
		};
		};
	};
	networking.firewall.allowedTCPPorts = [ 3500 80 443 8124 ];
}
