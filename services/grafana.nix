{ pkgs, config, ... }:
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
    listen = [{
      ssl = true;
      port = 2343;
      addr = "vivaldi.fritz.box";
    }];
  };

  #########
  # Prometheus
  #########

  services.prometheus = {
    enable = true;
    port = 9001;
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
    };
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
    listen = [{
      ssl = true;
      port = 9011;
      addr = "vivaldi.fritz.box";
    }];
  };

  #########
  # Loki
  #########

  services.loki = {
    enable = true;
    configFile = ./monitoring/loki.yaml;
  };

  systemd.services.promtail = {
    description = "Promtail service";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = ''
        		 ${pkgs.grafana-loki}/bin/promtail --config.file ${./monitoring/promtail.yaml}
        		'';
    };
  };

  #########
  # Nginx
  #########

  networking.firewall.allowedTCPPorts = [ 2343 9011 ];
}
