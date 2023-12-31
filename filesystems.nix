{ config, lib, pkgs, modulesPath, ... }:
{
  fileSystems."/" = {
      device = "/dev/mapper/xenon-nix";
      fsType = "f2fs";
      options = [
          "rw"
          "relatime"
          "lazytime"

          "active_logs=6"
          "alloc_mode=default"
          "background_gc=off"
          "extent_cache"
          "flush_merge"
          "fsync_mode=posix"
          "inline_data"
          "inline_dentry"
          "inline_xattr"
          "mode=adaptive"
          "no_heap"
      ];
  };

  fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/C06B-349A";
      fsType = "vfat";
  };

  fileSystems."/home" = {
      device = "/dev/mapper/main-home";
      fsType = "f2fs";
      options = [
           "lazytime"
           "relatime"
           "rw" 
           "x-systemd.automount"

           "active_logs=6"
           "alloc_mode=default"
           "background_gc=off"
           "extent_cache"
           "mode=adaptive"
           "flush_merge" 
           "fsync_mode=posix"
           "inline_data" 
           "inline_dentry" 
           "inline_xattr"
           "no_heap"
      ];
  };

  fileSystems."/one" = {
      device = "/dev/mapper/xenon-one";
      fsType = "f2fs";
      options = ["x-systemd.automount" "relatime" "lazytime"];
  };

  fileSystems."/zero" = {
      device = "/dev/mapper/argon-zero";
      fsType = "f2fs";
      options = ["x-systemd.automount" "relatime" "lazytime"];
  };

  fileSystems."/home/neg/music"={device="/one/music"; options=["bind" "nofail" "x-systemd.automount"];};
  fileSystems."/home/neg/torrent"={device="/one/torrent"; options=["bind" "nofail" "x-systemd.automount"];};
  fileSystems."/home/neg/vid"={device="/one/vid"; options=["bind" "nofail" "x-systemd.automount"];};
  fileSystems."/home/neg/games"={device="/one/games"; options=["bind" "nofail" "x-systemd.automount"];};
  fileSystems."/home/neg/.var"={device="/zero/flatpak"; options=["bind" "nofail" "x-systemd.automount"];};
  swapDevices = [];
}
