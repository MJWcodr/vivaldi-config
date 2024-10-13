{ pkgs, config, lib, ... }:

{
  options = {
    services.webdav = {
      enable = lib.mkDefault false;
      port = 8080;
      htpasswdFile = "/etc/nixos/services/webdav/htpasswd";
    };
  };



}
