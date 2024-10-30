{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "vivaldi" = {
        user = "matthias";
        hostname = "vivaldi";
      };
      "vivaldi-ext" = {
        user = "matthias";
        hostname = "vivaldi-ext";
      };
      "web0" = {
        user = "matthias";
        hostname = "wuensch.sh";
      };
      "smetana" = {
        user = "matthias";
        hostname = "gateway.mjwcodr.de";
      };
    };
  };
}
