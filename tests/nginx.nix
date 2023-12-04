{pkgs, config, ...}:

{
	systemd.services = {
		"nginx-test" = {
			enable = true;
			description = "";
			before = [ "nginx.service" ];
			after = [ "network.target" ];
			script = ''
				echo "nginx test"
				nginx -t /etc/nginx/nginx.conf
			'';
			path = [ pkgs.nginx ];
		};
	};
}
