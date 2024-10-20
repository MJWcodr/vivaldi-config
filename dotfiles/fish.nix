{ config, pkgs, ... }:

{

  # Add Zioxode as a program
  home.packages = with pkgs; [ zoxide ];

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };
  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "nix-env";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "00c6cc762427efe08ac0bd0d1b1d12048d3ca727";
          sha256 = "1hrl22dd0aaszdanhvddvqz3aq40jp9zi2zn0v1hjnf7fx4bgpma";
        };
      }
      {
        name = "fzf";
        src = pkgs.fetchFromGitHub {
          owner = "PatrickF1";
          repo = "fzf.fish";
          rev = "v10.0";
          sha256 = "CqRSkwNqI/vdxPKrShBykh+eHQq9QIiItD6jWdZ/DSM=";
        };
      }
    ];

    shellAliases = {
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";
      mkdir = "mkdir -p";
      senec =
        "nix-shell ~/Documents/Senec/shell.nix --run cd ~/Documents/Senec";
      # Git
      gst = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gd = "git diff";

      # Tui apps
      ls = "lsd";
      top = "btop";
      du = "dust";
      wtf = "wtfutil";

      # Zoxide
      z = "zoxide";

      backup = "~/.config/restic/backup.sh";
      backup-mount = "~/.config/restic/mount.sh";
      backup-purge = "~/.config/restic/purge.sh";

      # USBGuard
      usbl = "usbguard list-devices";
      usbw = "usbguard list-rules";
      usba = "usbguard allow-device";

      # Password Store
      kpm = "echo (pass keepass/keepass) | eval (pass keepass/merge_keepass )";

      # Update Music Library
      dmusic = "~/.config/entertainment/download-music.sh";
      emusic = "nvim /etc/nixos/dotfiles/entertainment/music.list";

      # checkin
      checkin = "/etc/nixos/dotfiles/bin/checkin.sh";

      # offload to nvidia gpu
      offload = "/etc/nixos/dotfiles/bin/offload.sh";
    };
    shellAbbrs = {
      m = "make";
      n = "nvim";
      c = "clear";
      o = "open";
      p = "python3";
      k = "kubectl";
      g = "git";

      # Git
      gsc = "git switch -c";
      gss = "git switch";
      gsm = "git switch main || git switch master";

      # Home Manager Edits
      hms = "home-manager switch";
      hme = "home-manager edit";
      hmcd = "cd ~/.config/home-manager";

    };

    shellInit = ''
            			# Greeting
            			function fish_greeting
            				figlet -f slant "$hostname"
            				fortune
            			end

            			set -l nix_shell_info (
             			 if test -n "$IN_NIX_SHELL"
                	 echo -n "<nix-shell> "
              		end

									export TODO_FILE="$HOME/Documents/Diary/20.\ Listen/10.\ ToDos/todo.txt"

      						export KAGI_API_KEY=$(pass dev/kagi.com/api-key)

      						export PATH="$HOME/.local/bin:$PATH"
      						export PATH="$HOME/.cargo/bin:$PATH"
      						export PATH="$HOME/go/bin:$PATH"
            			)

      						# fish_config theme save "Catppuccin Mocha" # currently broken
      						zoxide init fish --cmd j | source
      	     			'';
  };

  # programs.zioxide.enable = true;


  # move the fish theme to the right place
  #home.file.".config/fish/themes/mocha" = {
  #source = builtins.fetchurl "https://raw.githubusercontent.com/catppuccin/fish/main/themes/Catppuccin%20Mocha.theme";
  #

  # };
}
