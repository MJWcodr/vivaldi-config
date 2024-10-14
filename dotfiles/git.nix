{ pkgs, ... }: {


  home.packages = with pkgs; [
    pass-git-helper
  ];

  home.file.".config/pass-git-helper/git-pass-mapping.ini".text = ''
    [git.mjwcodr.de]
    	target=dev/git.mjwcodr.de
    	line_username=1
  '';

  programs = {
    git = {
      enable = true;
      userName = "Matthias Wünsch";
      userEmail = "matthias.wuensch@proton.me";
      extraConfig = {
        credential = {
          helper = "!type pass-git-helper >/dev/null && pass-git-helper $@";
        };
        core = {
          editor = "nvim";
          pager = "delta";
        };
        interactive = { diffFilter = "delta --color-only"; };
        delta = {
          navigation = true;
          light = false;
        };
        merge = { conflictStyle = "diff3"; };
        diff = { colorMoved = "default"; };
        push = { autoSetupRemote = true; };
      };
    };
  };

}
