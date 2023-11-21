{ config, ... }:

{

  # Import SSL Certificates
  # Secrets already imported in gitea.nix

  # Nginx Configuration
  services.nginx.virtualHosts."navidrome" = {
    sslCertificate = config.age.secrets."secrets/sslcert.crt.age".path;
    sslCertificateKey = config.age.secrets."secrets/sslcert.key.age".path;
    forceSSL = true;
    listen = [{
      port = 4533;
      ssl = true;
      addr = "vivaldi.fritz.box";
    }];

    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.navidrome.settings.Port}";
    };

  };


  services.navidrome.enable = true;
  services.navidrome.settings = {
    Address = "localhost";
    Port = 8090;
    MusicFolder = "/srv/music";
  };

  # Open Port 4533 for Navidrome
  networking.firewall.allowedTCPPorts = [ 4533 ];
}

