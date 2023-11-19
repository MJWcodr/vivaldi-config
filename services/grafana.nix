{pkgs, config, ...}:
{

#########
# Grafana
#########

	services.grafana = {
		enable = true;
		domain = "vivaldi.fritz.box";
		package = pkgs.grafana;
		port = 2342;
		addr = "127.0.0.1";
	};

	# Nginx reverse proxy
	services.nginx.virtualHosts."grafana" = {
		forceSSL = true;
		sslCertificate = config.age.secrets."sslcert".path;
		sslCertificateKey = config.age.secrets."sslkey".path;
		locations."/" = {
			proxyPass = "http://localhost:${toString config.services.grafana.port}";
			proxyWebsockets = true;
			extraConfig = ''
				proxy_set_header Host $host;
			'';
		};
		listen = [ {
			ssl = true;
			port = 2343;
			addr = "vivaldi.fritz.box";
		} ];
};

#########
# Prometheus
#########

  services.prometheus = {
    enable = true;
    port = 9001;
		scrapeConfigs = [
			{
				job_name = "prometheus";
				static_configs = [{
						targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
					}];
			}
		];
  };

	# Nginx reverse proxy
	services.nginx.virtualHosts."prometheus" = {
		forceSSL = true;
		sslCertificate = config.age.secrets."sslcert".path;
		sslCertificateKey = config.age.secrets."sslkey".path;
		locations."/" = {
			proxyPass = "http://localhost:${toString config.services.prometheus.port}";
			proxyWebsockets = true;
		};
		listen = [ {
			ssl = true;
			port = 9002;
			addr = "vivaldi.fritz.box";
		} ];
};

#########
# Nginx
#########

	networking.firewall.allowedTCPPorts = [ 2343 9002];
}
