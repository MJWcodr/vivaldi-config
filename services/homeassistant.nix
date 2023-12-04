{pkgs, config, ...}:
{

services.home-assistant = {
	enable = false;
	config = {
		http = {
			server_host = "localhost";
			trusted_proxies = [ "localhost" ];
			use_x_forwarded_for = true;
		};
	};

};


  services.nginx = {
    recommendedProxySettings = true;
    virtualHosts."home.example.com" = {
      extraConfig = ''
        proxy_buffering off;
      '';
      locations."/" = {
        proxyPass = "http://localhost:8123";
        proxyWebsockets = true;
      };
			listen = [ {
				addr = "vivaldi.fritz.box";	
				port = 8123;
			}];
    };
  };

	networking.firewall.allowedTCPPorts = [ 8123 ];
}
