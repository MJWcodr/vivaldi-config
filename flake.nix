{
  description = "Flake to manage my infrastructure";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    agenix.url = "github:ryantm/agenix";
    deploy-rs.url = "github:serokell/deploy-rs";
		stylix = {
			url = "github:danth/stylix";
			inputs.nixpkgs.follows = "nixpkgs";
		};
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
    website = {
			url = "git+https://git.mjwcodr.de/mjwcodr/website.git";
			inputs.nixpkgs.follows = "nixpkgs";
		};
    kagi.url = "git+https://git.mjwcodr.de/mjwcodr/kagi.git";
    qobuz-dl.url = "git+https://git.mjwcodr.de/mjwcodr/Qobuz-dl";
    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";
		comin = {
			url = "github:nlewo/comin";
			inputs.nixpkgs.follows = "nixpkgs";
		};
  };

  outputs = { self, nixpkgs, qobuz-dl, raspberry-pi-nix, agenix, stylix, website, comin
    , deploy-rs, kagi, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      theme = "catppuccin-mocha";
    in {
      packages.x86_64-linux.default = pkgs.mkShell {
        name = "Development Environment";
        buildInputs = with pkgs; [
          git
          pre-commit
          shellcheck
          nixfmt-rfc-style
          cabal-install
          pkgs.deploy-rs
        ];
      };
      nixosConfigurations = {
        # mjw-laptop is my main machine
        "mjw-laptop" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            # stylix is used to style my laptop
            stylix.nixosModules.stylix
            {
              stylix = {
                enable = true;
                image = ./wallpaper.jpg;
                polarity = "dark";
                # TODO: add this again
								# base16Scheme =
                #  "${pkgs.base16-schemes}/share/themes/${theme}.yaml";
                fonts = {
                  serif = {
                    package = pkgs.dejavu_fonts;
                    name = "DejaVu Serif";
                  };

                  sansSerif = {
                    package = pkgs.dejavu_fonts;
                    name = "DejaVu Sans";
                  };

                  monospace = {
                    package = pkgs.dejavu_fonts;
                    name = "DejaVu Sans Mono";
                  };

                  emoji = {
                    package = pkgs.noto-fonts-emoji;
                    name = "Noto Color Emoji";
                  };

                };
              };
            }
            # agenix is a secret manager
            agenix.nixosModules.default
            ./hosts/mjw-laptop/configuration.nix
            {
              environment.systemPackages = [
                agenix.packages.x86_64-linux.default
                kagi.defaultPackage.${system}
                qobuz-dl.packages.${system}.default
              ];
            }
          ];
        };
        # vivaldi is my main server
        "vivaldi" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            agenix.nixosModules.default
                        ./hosts/vivaldi/configuration.nix
            {
              environment.systemPackages =
                [ qobuz-dl.packages.${system}.default ];
            }
						comin.nixosModules.comin
          	{
            services.comin = {
              enable = true;
              remotes = [{
                name = "origin";
                url = "https://git.mjwcodr.de/mjwcodr/nixos-config.git";
                branches.main.name = "main";
              }];
            };
          	}
						];
        };

        # smetana is my vpn-gateway
        "smetana" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules =
            [ agenix.nixosModules.default ./hosts/smetana/configuration.nix
							 comin.nixosModules.comin
						{
              services.nginx = {
                enable = true;
                virtualHosts = {
                  "mjwcodr.de" = {
                    enableACME = true;
										forceSSL = true;
                    locations = {
                      "/" = { root = website.defaultPackage.x86_64-linux; };
                    };
                    listen = [
                      {
                        port = 443;
                        ssl = true;
                        addr = "mjwcodr.de";
                      }
                      {
                        port = 80;
                        ssl = false;
                        addr = "mjwcodr.de";
                      }
                    ];

                  };
                };
              };
              networking.firewall.allowedTCPPorts = [ 8000 ];
            }
						{
            services.comin = {
              enable = true;
							hostname = "smetana";
              remotes = [{
                name = "origin";
                url = "https://git.mjwcodr.de/mjwcodr/nixos-config.git";
                branches.main.name = "main";
								poller.period = 60;
              }];
            };
          	}
						];
        };
        # a raspberry pi 5
        "schubert" = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            agenix.nixosModules.default
            raspberry-pi-nix.nixosModules.raspberry-pi
            ./hosts/schubert/configuration.nix
            {
              raspberry-pi-nix.board = "bcm2712";
              hardware = {
                raspberry-pi = {
                  config = {
                    all = {
                      base-dt-params = {
                        # enable autoprobing of bluetooth driver
                        # https://github.com/raspberrypi/linux/blob/c8c99191e1419062ac8b668956d19e788865912a/arch/arm/boot/dts/overlays/README#L222-L224
                        krnbt = {
                          enable = true;
                          value = "on";
                        };
                      };
                    };
                  };
                };
              };
            }
          ];
        };
      };

      deploy.nodes."smetana" = {
        hostname = "gateway.mjwcodr.de";
        profiles.system = {
          sshUser = "root";
          user = "root";
          remoteBuild = true;
          path = deploy-rs.lib.x86_64-linux.activate.nixos
            self.nixosConfigurations."smetana";
        };
      };
      deploy.nodes."vivaldi" = {
        hostname = "vivaldi";
        profiles.system = {
          sshUser = "matthias";
          user = "matthias";
          remoteBuild = true;
          path = deploy-rs.lib.x86_64-linux.activate.nixos
            self.nixosConfigurations."vivaldi";
        };
      };
      # This is highly advised, and will prevent many possible mistakes
      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
