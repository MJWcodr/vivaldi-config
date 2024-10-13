{ pkgs, config, ... }:
let domain = "vivaldi.fritz.box";

in {
  services.invidious = {
    package = pkgs.invidious;
    enable = true;
    domain = "yt.mjwcodr.de";
    port = 3039;
    # settings
    settings.db.user = "invidious";
  };

  services.postgresql = {
    ensureDatabases = [ config.services.invidious.settings.db.user ];
    ensureUsers = [{
      name = config.services.invidious.settings.db.user;
      ensureDBOwnership = true;
    }];
  };

  services.nginx = {
    virtualHosts."invidious" = {
      locations."/".proxyPass =
        "http://localhost:${toString config.services.invidious.port}";
      listen = [{
        ssl = false;
        port = 3040;
        addr = domain;
      }];
    };
  };

  networking.firewall.allowedTCPPorts = [ 3040 ];
}
