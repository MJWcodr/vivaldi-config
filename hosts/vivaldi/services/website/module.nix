{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.website;
  website = import ./default.nix { inherit pkgs; };
in
{

  options = {
    services.website = {
      enable = mkEnableOption "Enable website service.";

      port = mkOption {
        description = "Port to listen on.";
        default = 8080;
        type = types.int;
      };
    };

  };
  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      virtualHosts = {
        "localhost" = {
          enableACME = false;
          locations = {
            "/" = {
              root = "${website}/";
              index = "index.html";
              # proxyPass = "http://localhost:8080";
            };
          };
          listen = [{
            port = cfg.port;
            addr = "0.0.0.0";
          }];
        };
      };
    };
  };
}
