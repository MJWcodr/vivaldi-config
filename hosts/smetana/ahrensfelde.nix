let
	domain = "ahrensfelde.wuensch.xyz";
	ip = "10.100.0.10";
	port = 8123;
in
{
	services.nginx = {
		enable = true;
		virtualHosts = {
			"${domain}" = {
				enableACME = true;
				forceSSL = true;
				locations = {
					"/" = {
						proxyPass = "http://${ip}:${toString port}";
						proxyWebsockets = true;
					};

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
		};
	};
}
