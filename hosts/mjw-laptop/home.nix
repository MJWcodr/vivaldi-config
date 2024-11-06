{ config, pkgs, ... }:
{

  # Import other Packages
  imports = [
    # Secrets
    # ./agenix.nix
    # <agenix/modules/age-home.nix>

    # Catpuccin Theme
    # Link: https://nix.catppuccin.com/getting-started/stable-nix.html
    # <catppuccin/modules/home-manager>
    # ./services/stylix.nix

    # Dotfiles
    ../../dotfiles/fish.nix
    ../../dotfiles/git.nix
    ../../dotfiles/ssh.nix
    ../../dotfiles/gnome/shortcuts.nix
    ../../dotfiles/entertainment/entertainment.nix

		../../dotfiles/neovim.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  nixpkgs.config.allowUnfreePredicate = _: true;

  home.username = "matthias";
  home.homeDirectory = "/home/matthias";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  home.packages = with pkgs; [
		tree
    restic
    rclone
    obsidian
    languagetool
    protonmail-bridge

		cachix

    fortune

    kubectl
    # helm # currently broken
    terraform
    terragrunt
    tflint
    tfsec
    terraform-docs

    (writeShellScriptBin "backup" ''
      ~/.config/restic/backup.sh
    '')

    nodejs_20
    drone-cli

    # Language Servers and Tools
    nixfmt-classic
    vale
    luajitPackages.lua-lsp
		ccls
    nixd
    luajitPackages.luacheck
    terraform-ls
    poetry
    # File management and Backup
    restic
    rclone
    croc

    mixxx
    kitty

    # Tui apps
    fff
    glow
    ripgrep
    fzf
    bat
    eza
    lsd
    wtf
    figlet
    sonixd

    # Git Tools
    commitizen
    pre-commit
    delta

    pass
    gnupg

    thunderbird

    # Dev Tools
    scrcpy

    # Fonts

    # Cloud
    # azure-cli

    # Coding & Developement
    go
    vscode
    glab
    neovim
    neovide # Neovim GUI
    yq
    direnv
    btop
    dust
    tea # Gitea CLI
    pandoc
    texliveSmall
    teams-for-linux
    slack
    xournalpp

    gnome-boxes
    gnome-themes-extra

    # Media
    # spotifY
    # spotify-tui
    spotifyd
    rhythmbox
    transmission_4
    gnome-podcasts
    # transmission_4-gtk

		tinymist
		bash-language-server

    # Communication
    element-desktop
    telegram-desktop
    signal-desktop
    discord

    keepassxc

		todo-txt-cli
		conky
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
		".config/conky.conf".source = ../../dotfiles/conky.conf;
    ".config/restic".source = ../../dotfiles/restic;
    ".config/rclone".source = ../../dotfiles/rclone;
    ".config/images".source = ../../dotfiles/images;
		".todo".source = ../../dotfiles/todo;
    # Configure autostart to run "/etc/nixos/dotfiles/bin/checkin.sh" on login
    ".config/autostart/checkin.desktop".text = ''
      			[Desktop Entry]
      			Type=Application
      			Exec=kgx --wait /etc/nixos/dotfiles/bin/checkin.sh && exit
      			Hidden=false
      			NoDisplay=false
      			X-GNOME-Autostart-enabled=true
      			Name[en_US]=Checkin
      			Name=Checkin
      			Comment[en_US]=Checkin
      			Comment=Checkin
      			'';
		# autostart for conky
		".config/autostart/conky.desktop".text = ''
			[Desktop Entry]
			Type=Application
			Exec=conky -c ${config.home.homeDirectory}/.config/conky.conf
			Hidden=false
			NoDisplay=false
			X-GNOME-Autostart-enabled=true
			Name[en_US]=Conky
			Name=Conky
			Comment[en_US]=Conky
			Comment=Conky
			'';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/matthias/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";

    PASSWORD_STORE_DIR = "/etc/nixos/dotfiles/password-store";

    RESTIC_PASSWORD_COMMAND = "pass show machine/restic";
    RCLONE_PASSWORD_COMMAND = "pass show machine/rclone";

    # Add Python and go to PATH
  };

  # Configure the gnome desktop
  # Setup Backup using Restic and Rclone


  # Add Applications to Gnome
  # As already mentioned
  targets.genericLinux.enable = true;
  xdg.mime.enable = true;

  # The critical missing piece for me
  xdg.systemDirs.data =
    [ "${config.home.homeDirectory}/.nix-profile/share/applications" ];

  # stylix = {
  #    enable = true;
  #    image = ./cuyp-aelbert-herdsmen-tending-cattle-1655-1660.jpg;
  #  };

  # Setup Password Store
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableFishIntegration = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };


  systemd.user.services.conky = {
    Unit = {
      Description = "Conky System Monitor";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
			Type = "simple";
      ExecStart = "${pkgs.writeShellScript "conky" ''
				# ${pkgs.conky}/bin/conky -c ${config.home.homeDirectory}/.config/conky.conf
				${pkgs.conky}/bin/conky
      ''}";
    };
  };

	services.copyq.enable = true;

  nixpkgs.config.permittedInsecurePackages = [ "nix-2.16.2" ];
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
