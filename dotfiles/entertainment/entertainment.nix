{ config, pkgs, ... }:

{
  home.file = {
    ".config/entertainment".source = ../../dotfiles/entertainment;
  };

  home.packages =
    [ (with pkgs.python3Packages; callPackage ./qobuz-dl/derivation.nix { }) ];
}
