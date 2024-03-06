{ config, pkgs, ... }:
let 
	freshrssInternalPort = 8089;
	freshrssExternalPort = 8090;
in
{
	age.secrets = {
		freshrss = {
			file = ../secrets/freshrss.age;
			owner = config.services.freshrss.user;
		};
	};

	# services.freshrss = {
	#	 enable = true;
	#	 baseUrl = "https://rss.mjwcodr.de";
	#	 defaultUser = "matthias";
	#	 passwordFile = config.age.secrets.freshrss.path; 
	#	 virtualHost = "vivaldi.fritz.box";
	# };

	virtualisation.oci-containers.containers.freshrss = {
		image = "freshrss/freshrss:latest";
		ports = [ "8089:80" ];
		volumes = [
			"/var/lib/freshrss:/var/www/FreshRSS/data"
		];
		environment = {
			CRON_MIN ="1,31";
			TZ="Europe/Berlin";
			FRESHRSS_INSTALL = ''
				--base_url https://rss.mjwcodr.de
				--default_user matthias
				--api_enabled
			'';
			FRESHRSS_USER = ''
				--user admin
				--password ${pkgs.lib.fileContents config.age.secrets.freshrss.path}
				--api_password ${pkgs.lib.fileContents config.age.secrets.freshrss.path}
				--language en
			'';
		};
	};

	services.nginx.virtualHosts."rss.mjwcodr.de" = {
		locations."/".proxyPass = "http://localhost:${toString freshrssInternalPort}";
		listen = [ 
			{
				ssl = false;
				port = freshrssExternalPort;
				addr = "vivaldi.fritz.box";
			}
		];
	};

	networking.firewall.allowedTCPPorts = [ freshrssExternalPort];
}

