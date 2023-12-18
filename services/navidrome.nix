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
      proxyPass =
        "http://localhost:${toString config.services.navidrome.settings.Port}";
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
			EnableSpotify = true;
			Spotify.ID = "77b794e641d24037b766e07015288fd4";
			Spotify.Secret = "04cae150c0f240d09a8865328618ac1e";
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
  networking.firewall.allowedTCPPorts = [ 4533 ];
}

