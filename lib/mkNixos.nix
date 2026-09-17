{ inputs }:
{ hostname, system ? "x86_64-linux", users ? [ "tom" ], extraModules ? [ ] }:
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    ../modules/nixos/common.nix
    ../hosts/${hostname}/configuration.nix
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserHomeDirectory = true;
      home-manager.users = builtins.listToAttrs (map
        (u: {
          name = u;
          value = import ../users/${u}.nix;
        })
        users);
    }
  ] ++ extraModules;
}
