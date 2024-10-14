{ pkgs, ... }: {
  services.gitea-actions-runner = {
    instances = {
      "runner1" = {
        enable = true;
        name = "runner1";
        url = "https://git.mjwcodr.de";
        tokenFile = "/etc/nixos/gitea-runner/token.txt";
        labels = [
          # provide a debian base with nodejs for actions
          "debian-latest:docker://node:18-bullseye"
          # fake the ubuntu name, because node provides no ubuntu builds
          "ubuntu-latest:docker://node:18-bullseye"
          # provide native execution on the host
          "nixos:docker://nixos:unstable"
          "native:host"
        ];
        hostPackages = with pkgs; [
          bash
          coreutils
          curl
          gawk
          gitMinimal
          gnused
          nodejs
          wget
        ];
      };
    };
  };

  services.resolved = { enable = true; };

}
