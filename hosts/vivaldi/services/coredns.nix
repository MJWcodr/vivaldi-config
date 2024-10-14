# services/coredns.nix

{ pkgs, ... }:

{
  environment.etc."coredns/blocklist.hosts".source = pkgs.fetchurl {
    url = "https://download.dnscrypt.info/blacklists/domains/mybase.txt";
    sha256 = "sha256-NWVY9YN+BvH6GUfNwajG+mPhm9VzHJ4wnu6211JhY/E=";
  };

  services.coredns = {
    enable = true;
    config = ''
      				.:53 {
      					hosts /etc/coredns/blocklist.hosts {
                fallthrough
              	}

      					# Forward all other requests to Cloudflare
      					forward . 1.1.1.1 1.0.0.1
      					cache

      				}
      				vivaldi.local {
      					template IN A  {
                  answer "{{ .Name }} 0 IN A 192.178.168.10"
                }
      				}
      			'';
  };

  # firewall
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  networking.networkmanager.insertNameservers = [ "127.0.0.1" ];
}
