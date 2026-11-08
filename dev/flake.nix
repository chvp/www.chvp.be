{
  description = "Development of personal website";
  inputs = {
    super.url = "../";
    nixpkgs.follows = "super/nixpkgs";
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
