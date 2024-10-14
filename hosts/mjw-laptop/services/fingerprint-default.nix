{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation {
  name = "godix";
  src = fetchTarball {
    url = "http://dell.archive.canonical.com/updates/pool/public/libf/libfprint-2-tod1-goodix/libfprint-2-tod1-goodix_0.0.4-0ubuntu1somerville1.tar.gz";
    sha256 = "sha256:05bd61s8lf9mc49k6dqrj53qb4bpqk3dlxw8xqlhjws9jxwj9ygx";
  };

  installPhase = ''
    		mkdir -p $out/bin
    		cp -r $src/* $out/bin
    	'';
}
