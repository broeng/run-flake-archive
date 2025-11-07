{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {

        apps.default = {
          name = "run-flake";
          type = "app";
          program = (pkgs.writeShellScript "run-flake" ''
            PATH=${pkgs.lib.makeBinPath [
              pkgs.coreutils
              pkgs.curl
              pkgs.unzip
              pkgs.git
              pkgs.gnutar
              pkgs.gzip
              pkgs.nix
            ]}
            ${builtins.readFile ./src/run-archive.sh}
          '').outPath;
        };

      }
    );
}
