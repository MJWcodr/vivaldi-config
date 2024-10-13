{
  description = "Flake to manage my infrastructure";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    agenix.url = "github:ryantm/agenix";
    deploy-rs.url = "github:serokell/deploy-rs";
    stylix.url = "github:danth/stylix";
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs = { self, nixpkgs, agenix, deploy-rs, stylix, pre-commit-hooks, ... }:
    let
      system = "x86_64-linux";
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
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
        inherit (self.checks.${system}.pre-commit-check) shellHook;
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
                base16Scheme =
                  "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
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
              environment.systemPackages =
                [ agenix.packages.x86_64-linux.default ];
            }
          ];
        };
        # smetana is my vpn-gateway
        "smetana" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules =
            [ agenix.nixosModules.default ./hosts/smetana/configuration.nix ];
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
      # This is highly advised, and will prevent many possible mistakes
      checks = builtins.mapAttrs
       (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
