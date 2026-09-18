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

      # Any directory under hosts/ other than hosts/template that contains a
      # `system` file becomes a real nixosConfigurations.<name> output —
      # adding a host means dropping in a directory, not editing this file.
      # hosts/template is excluded by name so it is never built, even though
      # it also carries a system file (kept only so it stays a complete,
      # consistent copy-source for the bootstrap script).
      hostNames = builtins.attrNames
        (nixpkgs.lib.filterAttrs
          (name: type: type == "directory" && name != "template")
          (builtins.readDir ./hosts));

      mkHostConfig = hostname:
        lib.mkNixos {
          inherit hostname;
          system = builtins.readFile (./hosts + "/${hostname}/system");
        };
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs hostNames mkHostConfig;

      homeConfigurations = {
        "tom@linux" = lib.mkHome {
          username = "tom";
          system = "x86_64-linux";
        };

        "tom@darwin" = lib.mkHome {
          username = "tom";
          system = "aarch64-darwin";
        };
      };

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [ pkgs.statix pkgs.deadnix pkgs.nixfmt ];
          };
        });

      apps = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          bootstrap-host = {
            type = "app";
            program = "${pkgs.writeShellApplication {
              name = "bootstrap-host";
              runtimeInputs = [ pkgs.coreutils pkgs.gnused ];
              text = builtins.readFile ./scripts/bootstrap-host.sh;
              meta.description = "Scaffold a new NixOS host from hosts/template";
            }}/bin/bootstrap-host";
          };
        });
    };
}
