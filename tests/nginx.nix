{ pkgs, config, ... }:

{
  systemd.services = {
    "nginx-test" = {
      enable = true;
      description = "";
      before = [ "nginx.service" ];
      after = [ "network.target" ];
      script = "	echo \"nginx test\"\n	nginx -t /etc/nginx/nginx.conf\n";
      path = [ pkgs.nginx ];
    };
  };
}
