{
  description = "Cross-platform Nix system configuration (NixOS + standalone home-manager)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      lib = import ./lib { inherit inputs; };

      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    {
      # No real NixOS host exists yet. hosts/template/ is copy-source only and
      # is deliberately not wired in here — see hosts/template/ and README.md.
      nixosConfigurations = { };

      homeConfigurations = {
        "tom@linux" = lib.mkHome {
          username = "tom";
          system = "x86_64-linux";
        };
      };

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [ pkgs.statix pkgs.deadnix pkgs.nixfmt-rfc-style ];
          };
        });
    };
}
