{ inputs }:
{
  mkNixos = import ./mkNixos.nix { inherit inputs; };
  mkHome = import ./mkHome.nix { inherit inputs; };
}
