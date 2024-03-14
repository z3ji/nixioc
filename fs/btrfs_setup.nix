{
  pkgs,
  fs,
  host,
  util,
  ...
}: let
  join = pkgs.lib.strings.concatStringsSep;
in
  pkgs.writeShellApplication {
    name = "btrfs_setup_${host}";
    runtimeInputs = with pkgs; [btrfs-progs];
    text = ''
      # Auto-generated by btrfs_setup.nix. DO NOT EDIT.
      read -p "This will apply the config to ${join ", " (util.mapKeys fs.order (dev: fs.devices.${dev}.path))}. Are you sure? [y/N] " -r
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then exit 1; fi
      set -x

      ROOT=/mnt

      ${join "" (util.mapKeys fs.order (devName: let
        dev = fs.devices.${devName};
        subvols = fs.subvols.${devName} or [];
      in ''
        : "Setting up ${devName} (${dev.path})..."
        MNT=/setup/${devName}/
        mkdir -p "$MNT"
        mount ${dev.path} "$MNT"
        : "Checking for existing subvolumes..."
        if compgen -G "$MNT/@*"; then
            : "Some subvolumes already exist on ${devName} (${dev.path})."
            : "Do you want to proceed? Existing subvolumes will be re-used."
            : "This might cause trouble if they're not compatible with the new config."
            read -p "[y/N] " -r
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then umount $MNT; exit 1; fi
        fi
        : "Creating subvolumes..."
        ${join "" (util.mapKeys subvols (sub: ''
          : "Creating subvolume ${sub.name} at ${sub.mount} if it doesn't exist"
          if [ ! -d "$MNT/${sub.name}" ]; then
              btrfs subvolume create "$MNT/${sub.name}";
          else
              : "Subvolume ${sub.name} already exists! Re-using it, if something fails here fix it manually."
          fi
          ${join "" (util.mapKeys ([sub.mount] ++ (sub.additional_mounts or [])) (mount: ''
            : "Mounting ${sub.name} at ${mount}"
            mkdir -p "$ROOT${mount}"
            mount -o "subvol=${sub.name},noatime,compress=${sub.compress}" ${dev.path} "$ROOT${mount}"
          ''))}
        ''))}
        umount $MNT
        : "Mounting additional paths..."
        ${join "" (util.mapKeys dev.mounts or [] (mount: ''
          mkdir -p "$ROOT${mount}"
          mount ${dev.path} "$ROOT${mount}"
        ''))}
      ''))}
    '';
  }
