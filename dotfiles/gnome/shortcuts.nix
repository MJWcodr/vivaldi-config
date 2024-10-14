{ pkgs, config, ... }: {

  home.packages = with pkgs; [
    fira-code-nerdfont

    gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.user-themes
    gnomeExtensions.vitals
  ];

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      picture-uri = "file:///home/matthias/.config/images/buttons.png";
      picture-options = "zoom";
    };
    "org/gnome/evolution/calendar" = {
      "show-week-numbers" = true;
      "week-start-day" = "monday";
    };

    "org/gnome/shell" = {
      "favorite-apps" = [
        "firefox.desktop"
        "org.gnome.Console.desktop"
        "org.gnome.Nautilus.desktop"
        "org.gnome.Music.desktop"
        "org.gnome.Thunderbird.desktop"
      ];
      disable-user-extensions = false;
      "enabled-extensions" = [
        "Vitals@CoreCoding.com"
        "sound-output-device-chooser@kgshank.net"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
      ];
    };
    # "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
    #	name = "kgx";
    #	binding = "<Super>t";
    #	command = "kgx";
    #};

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" =
      {
        binding = "<Super>t";
        command = "kgx";
        name = "Terminal";
      };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" =
      {
        "binding" = "<Super>e";
        "command" = "gnome-text-editor";
        "name" = "Gnome Text Editor";
      };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" =
      {
        "binding" = "<Super>n";
        "command" = "neovide";
        "name" = "neovide";
      };
  };

  home.sessionVariables.GTK_THEME = "${config.gtk.theme.name}";
}
