{ pkgs ? import <nixpkgs> { } }:

let cv = import ./CV/default.nix { inherit pkgs; };
in pkgs.stdenv.mkDerivation rec {
  pname = "website";
  version = "0.1.0";

  src = ./.;

  buildInputs = with pkgs; [ pandoc coreutils findutils ];

  configurePhase = "";

  buildPhase =
    "	mkdir -p $out\n	for f in $(find $src/src/ -name '*.md'); do\n		pandoc --template $src/templates/template.html -s -o $out/$(basename $f .md).html $f\n	done\n";

  installPhase =
    "	cp $src/src/* $out\n	cp $src/static/* $out\n\n	cp ${cv}/cv.pdf $out\n\n	";
}
