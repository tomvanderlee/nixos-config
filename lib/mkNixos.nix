{ inputs }:
{ hostname, system ? "x86_64-linux", users ? [ "tom" ], extraModules ? [ ] }:
let
  unfreeAllowlist = import ./unfree-allowlist.nix;
in
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    {
      nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (inputs.nixpkgs.lib.getName pkg) unfreeAllowlist;
    }
    ../modules/nixos/common.nix
    ../hosts/${hostname}/configuration.nix
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users = builtins.listToAttrs (map
        (u: {
          name = u;
          value = import ../users/${u}.nix;
        })
        users);
    }
  ] ++ extraModules;
}
