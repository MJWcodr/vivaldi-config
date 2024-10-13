{ pkgs, conf, ... }:

{
  home.packages = with pkgs; [ tmux ];
  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    secureSocket = true;
    prefix = "C-a";
    mouse = true;
    clock24 = true;
    terminal = "screen-256color";
    # plugins = {};
  };
}
