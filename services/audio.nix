{ config, ... }:

{
  services.minidlna = {
    enable = true;
    settings = {
      port = 8200;
      media_dir = [ "/srv/music" ];
    };
    openFirewall = true;
  };
}
