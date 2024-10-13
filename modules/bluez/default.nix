{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation {
  name = "bluez";
  src = pkgs.fetchgit {
    url = "https://git.kernel.org/pub/scm/bluetooth/bluez.git";
    rev = "5.57";
    sha256 = "sha256-zDAJze5+vIJPlNG8mNc0Ldbj101GjJfzwDMxbYSjph0=";
  };


  buildPhase = ''
    		cd $src
    		./configure  --prefix=$out

    		make

    	'';


}
