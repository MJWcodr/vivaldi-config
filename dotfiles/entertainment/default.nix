{ pkgs ? import <nixpkgs> { } }:
let
  poetry2nix = pkgs.callPackage
    (pkgs.fetchFromGitHub {
      owner = "nix-community";
      repo = "poetry2nix";
      sha256 = "QSGP2J73HQ4gF5yh+MnClv2KUKzcpTmikdmV8ULfq2E=";
      rev = "7acb78166a659d6afe9b043bb6fe5cb5e86bb75e";
    })
    { };
  env = poetry2nix.mkPoetryEnv { projectDir = ./.; };
in
env
