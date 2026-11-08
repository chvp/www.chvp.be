{
  description = "Development of personal website";
  inputs = {
    super = {
      url = "../";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs: {
    devShells = builtins.mapAttrs (
      system: pkgs':
      let
        pkgs = pkgs'.extend inputs.devshell.overlays.default;
      in
      {
        "www.chvp.be" = pkgs.devshell.mkShell {
          name = "Website";
          packages = with pkgs; [
            nixfmt
            zola
          ];
        };
        default = inputs.self.devShells.${system}."www.chvp.be";
      }
    ) inputs.nixpkgs.legacyPackages;
  };
}
