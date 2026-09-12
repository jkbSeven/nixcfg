{
  description = "Python3 + uv development";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    {
      nixpkgs,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.python3
              pkgs.uv
            ];

            env = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
              /*
                Attribution: pyproject-nix/pyproject.nix (MIT license)
                https://github.com/pyproject-nix/pyproject.nix/blob/6a8a7881d75b6f98967e7b8069f4ead331384301/templates/impure/flake.nix

                Explanation:
                Python libraries often load native shared objects using dlopen(3).
                Setting LD_LIBRARY_PATH makes the dynamic library loader aware of libraries without using RPATH for lookup.
              */
              LD_LIBRARY_PATH = lib.makeLibraryPath pkgs.pythonManylinuxPackages.manylinux1;
            };

            shellHook = ''
              [ -d .venv ] && . .venv/bin/activate
            '';
          };
        }
      );
    };
}
