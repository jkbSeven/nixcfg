{
  description = "NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
      nixpkgs-unstable,
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
        thinkpad6 = nixpkgs-unstable.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/thinkpad6/configuration.nix
            home-manager.nixosModules.home-manager
            { home-manager.users.jkb = import ./home.nix; }
          ];
        };

        pc = nixpkgs-unstable.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/pc/configuration.nix
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

        control-plane =
          { name, config, ... }:
          {
            imports = [
              ./hosts/vm.nix
              ./modules/homelab
            ];

            networking.hostName = name;

            homelab.monitoring.enable = true;
            homelab.services.victoria-metrics = {
              enable = true;
              nodes = ["localhost"];
            };
            homelab.services.grafana.enable = true;


            deployment.targetUser = "admin";
          };
      };

      formatter.${system} = pkgs.nixfmt;
    };
}
