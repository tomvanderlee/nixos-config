{ inputs }:
{ username, system, extraModules ? [ ] }:
inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  modules = [ ../users/${username}.nix ] ++ extraModules;
}
