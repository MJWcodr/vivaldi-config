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
		# Homer
		"home.${domain}" = {
				locations."/".proxyPass = "http://localhost:8050";
				listen = [
		 			{
						port = 90;
			 			addr = "10.100.0.2";
					}
			];
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
		};
	};
	networking.firewall.allowedTCPPorts = [ 3500 ];
}
