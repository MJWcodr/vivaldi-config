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
    }
		{
			port = 4532;
			ssl = false;
			addr = "vivaldi.fritz.box";
		}
		];

    locations."/" = {
      proxyPass =
        "http://localhost:${toString config.services.navidrome.settings.Port}";
			proxyWebsockets = true;
    };
  };

  services.navidrome = {
    enable = true;
    settings = {
      Address = "localhost";
      Port = 8090;
      MusicFolder = "/srv/music";
      EnableGravatar = true;
      EnableLastFM = true;
			LastFM.ApiKey = "3019cf099934325a4dc53f70095c6ce5";
			LastFM.Secret = "660436d78c246815936a5806848e2df1";
    };
  };

	# bonob
	virtualisation.oci-containers.containers.bonob = {
		image = "docker.io/simojenki/bonob";
		environment = {
			BNB_SONOS_AUTO_REGISTER = "true";
			BNB_SONOS_DEVICE_DISCOVERY = "true";
		};
		ports = [ "4534:4534" ];
	};
  # Open Port 4533 for Navidrome
  networking.firewall.allowedTCPPorts = [ 4533 4532 ];
}
