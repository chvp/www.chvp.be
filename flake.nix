{
  description = "My personal website";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshell = {
      url = "github:numtide/devshell";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };
  outputs = { self, nixpkgs, devshell, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; overlays = [ devshell.overlays.default ]; };
          pkg = pkgs.stdenv.mkDerivation {
            pname = "www.chvp.be";
            version = "unstable";
            src = ./src;

            buildPhase = ''
              ${pkgs.zola}/bin/zola build
            '';

            installPhase = ''
              cp -r public $out
            '';
          };
          shell = pkgs.devshell.mkShell {
            name = "Website";
            packages = with pkgs; [
              nixpkgs-fmt
              zola
            ];
          };
        in
        {
          packages = {
            default = pkg;
            "www.chvp.be" = pkg;
          };
          devShells = rec {
            default = shell;
            "www.chvp.be" = shell;
          };
        }
      ) // {
      overlays.default = (curr: prev: {
        "www.chvp.be" = self.packages.${curr.system}.default;
      });
    };
}
