{
  config,
  pkgs,
  lib,
  ...
}:

{

  fileSystems."/mnt/nextcloud_data" = {
    device = "nas.jkb7.dev:/mnt/main/nextcloud_data";
    fsType = "nfs4";
    options = [ "noatime" ];
  };

  users.users.nextcloud = {
    isSystemUser = true;
    group = "nextcloud";
    uid = 4000; # matching the one on NAS
  };

  users.groups.nextcloud.gid = 4000; # matching the one on NAS

  services.nextcloud.enable = true;
  services.nextcloud.package = pkgs.nextcloud33;
  services.nextcloud.hostName = "drive.jkb7.dev";
  services.nextcloud.config.adminpassFile = "/var/lib/secrets/nextcloud";
  services.nextcloud.config.dbtype = "pgsql";
  services.nextcloud.database.createLocally = true;
  services.nextcloud.datadir = "/mnt/nextcloud_data";

  systemd.services.remotefs-tmpfiles = {
    description = "Ensure nextcloud config directories are created after NFS share is mounted";
    path = [ "systemd-tmpfiles" ];
    script = "systemd-tmpfiles --create --remove --exclude-prefix=/dev";
    after = [ "remote-fs.target" ];
    requires = [ "remote-fs.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };
  };

  systemd.services.nextcloud-setup.after = [ "remotefs-tmpfiles.service" ];
  systemd.services.nextcloud-setup.requires = [ "remotefs-tmpfiles.service" ];

  systemd.services.phpfpm-nextcloud.after = [ "remotefs-tmpfiles.service" ];
  systemd.services.phpfpm-nextcloud.requires = [ "remotefs-tmpfiles.service" ];

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
