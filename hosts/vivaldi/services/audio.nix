{ config, ... }:

{
  services.minidlna = {
    enable = true;
    settings = {
			friendly_name = "NixOS Media Server";
      port = 8200;
      media_dir = [ "/srv/music" ];
			inotify = "yes";
    };
    openFirewall = true;
  };
}
