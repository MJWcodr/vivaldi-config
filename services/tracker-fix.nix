{ pkgs, ... }: {

  systemd.user.services = {
    "gnome-tracker" = {
      enable = true;
      script = "	${pkgs.tracker}/bin/tracker3 daemon -f\n";
    };
  };

}
