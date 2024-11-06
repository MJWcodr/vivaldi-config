{ pkgs, config, ... }:

let
  ntfyPortInternal = 8499;
  ntfyPort = 8500;
  localDomain = "vivaldi.fritz.box";

in {

  ###########
  # Ntfy
  ###########
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://nfty.mjwcodr.de";
      listen-http = ":${toString ntfyPortInternal}";
    };
  };

  ###########
  # Nginx
  ###########
  services.nginx.virtualHosts = {
    # Local
    "${localDomain}" = {
      sslCertificate = config.age.secrets.sslcert.path;
      sslCertificateKey = config.age.secrets.sslkey.path;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString ntfyPortInternal}";
      };
      listen = [{
        ssl = true;
        port = ntfyPort;
        addr = localDomain;
      }];

    };
  };

  networking.firewall.allowedTCPPorts = [ ntfyPort ];
}
