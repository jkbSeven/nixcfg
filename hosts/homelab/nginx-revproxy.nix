{ config, pkgs, lib, ... }:
{

  security.acme = {
    acceptTerms = true;

    defaults = {
      email = "Jacob202@pm.me";
      dnsProvider = "cloudflare";
      environmentFile = "/var/lib/secrets/cloudflare";
    };

    certs = {
      "jkb7.dev" = {
        domain = "*.jkb7.dev";
        group = "nginx";
      };
    };
  };

  services.nginx = {
    enable = true;

    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    recommendedOptimisation = true;

    virtualHosts = {

      "photos.jkb7.dev" = {
        forceSSL = true;
        enableACME = true;

        # https://github.com/NixOS/nixpkgs/issues/210807
        acmeRoot = null;

        locations."/" = {
          proxyPass = "http://immich.srv.jkb7.dev:30041";
          proxyWebsockets = true;
          extraConfig = "proxy_pass_header Authorization;";
        };
      };

      "proxmox.jkb7.dev" = {
        forceSSL = true;
        enableACME = true;

        # https://github.com/NixOS/nixpkgs/issues/210807
        acmeRoot = null;

        locations."/" = {
          proxyPass = "https://proxmox.srv.jkb7.dev:8006";
          proxyWebsockets = true;
          extraConfig = "proxy_pass_header Authorization;";
        };
      };

    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
