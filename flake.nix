{
  description = "NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena = {
      url = "github:zhaofengli/colmena/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      colmena,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      nixosConfigurations = {
        thinkpad6 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/thinkpad6/configuration.nix
            home-manager.nixosModules.home-manager
            { home-manager.users.jkb = import ./home.nix; }
          ];
        };

        vm-base = nixpkgs.lib.nixosSystem {
          inherit system;

          modules = [
            ./hosts/vm.nix
          ];
        };
      };

      templates = {
        C = {
          path = ./templates/C;
          description = "Baseline C env for Linux with gcc and clang";
        };
      };

      colmenaHive = colmena.lib.makeHive {
        meta = {
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = [ ];
          };
        };

        nginx =
          { name, ... }:
          {
            imports = [
              ./hosts/vm.nix
              ./hosts/homelab/nginx-revproxy.nix
            ];

            networking.hostName = name;

            deployment.targetUser = "admin";
          };

        nextcloud =
          { name, ... }:
          {
            imports = [
              ./hosts/vm.nix
              ./hosts/homelab/nextcloud.nix
            ];

            networking.hostName = name;

            deployment.targetUser = "admin";
          };
      };

      formatter.${system} = pkgs.nixfmt;
    };
}
