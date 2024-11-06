{ pkgs, config, ... }:
let
  bookshelfportinternal = 6999;
  bookshelfportexternal = 7000;
  domain = "vivaldi.fritz.box";
in {
  services.audiobookshelf = {
    enable = true;
    port = bookshelfportinternal;
    # dataDir = "/srv/entertainment/audiobooks/";
    user = "root";
  };

  services.nginx.virtualHosts."audiobooks.example.com" = {
    sslCertificate = config.age.secrets.sslcert.path;
    sslCertificateKey = config.age.secrets.sslkey.path;
    locations."/" = {
      proxyPass = "http://localhost:${toString bookshelfportinternal}";
    };
    listen = [{
      port = bookshelfportexternal;
      ssl = false;
      addr = domain;
    }];
  };

  networking.firewall.allowedTCPPorts = [ bookshelfportexternal ];
}
