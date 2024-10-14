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
    restic
    rclone
    protonmail-bridge

    fortune
    (writeShellScriptBin "backup" ''
      ~/.config/restic/backup.sh
    '')
    # Language Servers and Tools
    nixfmt-classic
    vale
    luajitPackages.lua-lsp
    nixd
    luajitPackages.luacheck
    # File management and Backup
    restic
    rclone
    croc

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

    # Dev Tools
    scrcpy

    # Fonts

    # Cloud
    # azure-cli

    # Coding & Developement
    go
    glab
    neovim
    yq
    direnv
    btop
    dust
    tea # Gitea CLI
    pandoc
    texliveSmall

    # Media
    # spotifY
    # spotify-tui
    spotifyd
    rhythmbox
    transmission_4
    gnome-podcasts
    # transmission_4-gtk

    # Communication
    #element-desktop
    #telegram-desktop
    #signal-desktop
    #discord

    #keepassxc
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    ".config/restic".source = ../../dotfiles/restic;
    ".config/rclone".source = ../../dotfiles/rclone;
    ".config/images".source = ../../dotfiles/images;
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

  # Manage Neovim
  xdg.configFile.nvim = {
    source = ../../dotfiles/neovim;
    recursive = true;
  };

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

  nixpkgs.config.permittedInsecurePackages = [ "nix-2.16.2" ];
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
