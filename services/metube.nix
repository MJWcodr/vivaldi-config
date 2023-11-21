{ config, pkgs, ... }:
let
  internalMetubePort = 8081;
  externalMetubePort = 8090;
  MetubeVolume = "/srv/metube";
in {

  ##########
  # Metube
  ##########

  virtualisation.oci-containers.containers = {
    "metube" = {
      image = "ghcr.io/alexta69/metube:latest";
      ports = [ "8081:8081" ];
      volumes = [ "${MetubeVolume}:/downloads" ];
    };
  };

  ##########
  # Nginx
  ##########

  services.nginx = {
    enable = true;
    virtualHosts."metube" = {
      locations."/" = { proxyPass = "http://localhost:8081"; };
      forceSSL = true;
      sslCertificate = config.age.secrets."sslcert".path;
      sslCertificateKey = config.age.secrets."sslkey".path;
      listen = [{
        ssl = true;
        port = externalMetubePort;
        addr = "vivaldi.fritz.box";
      }];
    };
  };

  networking.firewall.allowedTCPPorts = [ externalMetubePort ];
}
