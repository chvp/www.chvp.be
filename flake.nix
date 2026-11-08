{
  description = "My personal website";

  inputs.nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";

  outputs = inputs: {
    packages = builtins.mapAttrs (system: pkgs: {
      "www.chvp.be" = pkgs.callPackage ./default.nix { };
      default = inputs.self.packages.${system}."www.chvp.be";
    }) inputs.nixpkgs.legacyPackages;
    overlays.default = (
      self: super: {
        "www.chvp.be" = self.callPackage ./default.nix { };
      }
    );
  };
}
