{ ... }:
let
  foreignHostIP = "10.100.0.2";
  domain = "mjwcodr.de";

  # gateway
  gatewayHost = "gateway.${domain}";

  # home
  homeHost = "home.${domain}";
  homeHostPort = "8123";

  # music
  navidromeHostPort = "4533";
  navidromeHost = "music.${domain}";

  # photos
  photosHostPort = "2352";
  photosHost = "photos.${domain}";

  # paperless
  paperlessHostPort = "9000";
  paperlessHost = "paper.${domain}";

  # vikunja
  vikunjaHostPort = "3500";
  vikunjaHost = "tasks.${domain}";

  # Ntfy
  ntfyHostPort = "8500";
  ntfyHost = "ntfy.${domain}";

  # Jellyfin
  jellyfinHostPort = "8096";
  jellyfinHost = "movies.${domain}";

  radicalePort = "5232";
  radicaleHost = "cal.${domain}";

  freshrssHostPort = "8090";
  freshrssHost = "rss.${domain}";

  gitHost = "git.${domain}";
  gitHostPort = "3001";

  hedgedoc = "doc.${domain}";
  hedgedocPort = "6700";

  websitePort = "8000";

  # webdav
  webdavHost = "dav.${domain}";
  webdavPort = "9100";

in {

  services.nginx = {
    enable = true;

    virtualHosts = {
      "${domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://${foreignHostIP}:${websitePort}";
          proxyWebsockets = true;
          root = "/etc/nixos/nginx/${gatewayHost}";
        };
        listen = [
          {
            ssl = true;
            port = 443;
            addr = "${domain}";
          }
          {
            ssl = false;
            port = 80;
            addr = "${domain}";
          }
        ];
      };
      "${gatewayHost}" = {
        enableACME = true;
        forceSSL = true;
        root = "/etc/nixos/nginx/${gatewayHost}";
        listen = [{
          ssl = true;
          port = 443;
          addr = "gateway.${domain}";
        }];
      };
      # home.mjwcodr.de
      "${homeHost}" = {
        enableACME = true;
        forceSSL = true;
        # forceSSL = true;
        locations."/" = {
          proxyPass = "http://${foreignHostIP}:${homeHostPort}";
          proxyWebsockets = true;
          extraConfig =
            "	proxy_set_header Upgrade $http_upgrade;\n	proxy_set_header Connection \"upgrade\";\n	proxy_buffering off;\n";
        };
        listen = [
          {
            ssl = false;
            port = 80;
            addr = "home.${domain}";
          }
          {
            ssl = true;
            port = 443;
            addr = "home.${domain}";
          }
        ];
      };

      "${navidromeHost}" = {
        enableACME = true;
        addSSL = true;
        locations."/".proxyPass =
          "http://${foreignHostIP}:${navidromeHostPort}";
        listen = [
          {
            port = 80;
            addr = "${navidromeHost}";
          }
          {
            ssl = true;
            port = 443;
            addr = "${navidromeHost}";
          }
        ];
      };
      "photos.${domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://${foreignHostIP}:${photosHostPort}";
          proxyWebsockets = true;
          extraConfig =
            "	proxy_set_header Upgrade $http_upgrade;\n	proxy_set_header Connection \"upgrade\";\n	proxy_buffering off;\n";
        };
        listen = [
          {
            port = 80;
            addr = "photos.${domain}";
          }
          {
            ssl = true;
            port = 443;
            addr = "photos.${domain}";
          }
        ];
      };
      "paper.${domain}" = {
        enableACME = true;
        addSSL = true;
        locations."/".proxyPass =
          "http://${foreignHostIP}:${paperlessHostPort}";
        listen = [
          {
            port = 80;
            addr = "paper.${domain}";
          }
          {
            ssl = true;
            port = 443;
            addr = "paper.${domain}";
          }
        ];
      };
      "tasks.${domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://${foreignHostIP}:${vikunjaHostPort}";
        listen = [
          {
            port = 80;
            addr = "tasks.${domain}";
          }
          {
            ssl = true;
            port = 443;
            addr = "tasks.${domain}";
          }
        ];
      };
      "ntfy.${domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://${foreignHostIP}:${ntfyHostPort}";
        listen = [
          {
            port = 80;
            addr = "ntfy.${domain}";
          }
          {
            ssl = true;
            port = 443;
            addr = "ntfy.${domain}";
          }
        ];
      };
      "movies.${domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://${foreignHostIP}:${jellyfinHostPort}";
        listen = [
          {
            port = 80;
            addr = "movies.${domain}";
          }
          {
            ssl = true;
            port = 443;
            addr = "movies.${domain}";
          }
        ];
      };
      "cal.${domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://${foreignHostIP}:${radicalePort}";
        listen = [
          {
            port = 80;
            addr = "cal.${domain}";
          }
          {
            ssl = true;
            port = 443;
            addr = "cal.${domain}";
          }
        ];
      };
      "rss.${domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://${foreignHostIP}:${freshrssHostPort}";
        listen = [
          {
            port = 80;
            addr = "rss.${domain}";
          }
          {
            ssl = true;
            port = 443;
            addr = "rss.${domain}";
          }
        ];
      };
      "git.${domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://${foreignHostIP}:${gitHostPort}";
          extraConfig = ''
            					client_max_body_size 512M;
                    	proxy_set_header Connection $http_connection;
                    	proxy_set_header Upgrade $http_upgrade;
                    	proxy_set_header Host $host;
                    	proxy_set_header X-Real-IP $remote_addr;
                    	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    	proxy_set_header X-Forwarded-Proto $scheme;
            				'';
        };

        listen = [
          {
            port = 80;
            addr = "git.${domain}";
          }
          {
            ssl = true;
            port = 443;
            addr = "git.${domain}";
          }
        ];
      };

      "doc.${domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://${foreignHostIP}:${hedgedocPort}";
          extraConfig =
            "	client_max_body_size 512M;\n	proxy_set_header Connection $http_connection;\n	proxy_set_header Upgrade $http_upgrade;\n	proxy_set_header Host $host;\n	proxy_set_header X-Real-IP $remote_addr;\n	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n	proxy_set_header X-Forwarded-Proto $scheme;\n";
        };

        listen = [
          {
            port = 80;
            addr = "doc.${domain}";
          }
          {
            ssl = true;
            port = 443;
            addr = "doc.${domain}";
          }
        ];
      };
      ${webdavHost} = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://${foreignHostIP}:${webdavPort}";
          extraConfig =
            "	client_max_body_size 100G;\n	proxy_set_header Connection $http_connection;\n	proxy_set_header Upgrade $http_upgrade;\n	proxy_set_header Host $host;\n	proxy_set_header X-Real-IP $remote_addr;\n	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n	proxy_set_header X-Forwarded-Proto $scheme;\n";
        };

        listen = [
          {
            port = 80;
            addr = "${webdavHost}";
          }
          {
            ssl = true;
            port = 443;
            addr = "${webdavHost}";
          }
        ];
      };
    };
  };
  security.acme = {
    email = "matthias.wuensch@protonmail.com";
    acceptTerms = true;
  };

  networking.firewall.allowedTCPPorts = [ 80 443 8123 ];
  networking.firewall.enable = true;
}
