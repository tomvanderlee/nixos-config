{ inputs }:
{ username, system, extraModules ? [ ] }:
let
  unfreeAllowlist = import ./unfree-allowlist.nix;
in
inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfreePredicate = pkg:
      builtins.elem (inputs.nixpkgs.lib.getName pkg) unfreeAllowlist;
  };
  modules = [ ../users/${username}.nix ] ++ extraModules;
}
