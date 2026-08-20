{
  description = "My personal website";
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs:
    {
      packages = builtins.mapAttrs
        (system: pkgs: {
          "www.chvp.be" = pkgs.callPackage ./default.nix { };
          default = inputs.self.packages.${system}."www.chvp.be";
        })
        inputs.nixpkgs.legacyPackages;
      devShells = builtins.mapAttrs
        (system: pkgs':
          let
            pkgs = pkgs'.extend inputs.devshell.overlays.default;
          in
          {
            "www.chvp.be" = pkgs.devshell.mkShell {
              name = "Website";
              packages = with pkgs; [
                nixpkgs-fmt
                zola
              ];
            };
            default = inputs.self.devShells.${system}."www.chvp.be";
          }
        )
        inputs.nixpkgs.legacyPackages;
      overlays.default = (curr: prev: {
        "www.chvp.be" = inputs.self.packages.${curr.stdenv.hostPlatform.system}.default;
      });
    };
}
