{ config, ... }: {

  virtualisation.oci-containers.containers = {
    "homer" = {
      image = "b4bz/homer:latest";
      volumes = [ "/etc/nixos/services/homer/:/www/assets:ro" ];
      autoStart = true;
      ports = [ "8050:8080" ];
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "vivaldi.mjwcodr.de" = {
        sslCertificate = config.age.secrets."secrets/sslcert.crt.age".path;
        sslCertificateKey = config.age.secrets."secrets/sslcert.key.age".path;
        locations."/".proxyPass = "http://localhost:8050";
        forceSSL = true;
        listen = [
          {
            ssl = true;
            port = 443;
            addr = "vivaldi.fritz.box";
          }
          {
            ssl = false;
            port = 80;
            addr = "vivaldi.fritz.box";
          }
        ];
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 443 80 90 ];
}
