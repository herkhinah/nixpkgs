{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.virtualisation.anbox;
  inherit (config.boot) kernelPackages;
  inherit (kernelPackages) kernel;

  # Inverted condition from `meta.broken` on `kernelPackages.anbox`.
  useAnboxModules = kernel.kernelAtLeast "4.4" && kernel.kernelOlder "5.5";
  addrOpts = v: addr: pref: name: {
    address = mkOption {
      default = addr;
      type = types.str;
      description = ''
        IPv${toString v} ${name} address.
      '';
    };

    prefixLength = mkOption {
      default = pref;
      type = types.addCheck types.int (n: n >= 0 && n <= (if v == 4 then 32 else 128));
      description = ''
        Subnet mask of the ${name} address, specified as the number of
        bits in the prefix (<literal>${if v == 4 then "24" else "64"}</literal>).
      '';
    };
  };

  finalImage = if cfg.imageModifications == "" then cfg.image else ( pkgs.callPackage (
    { runCommandNoCC, squashfsTools }:

    runCommandNoCC "${cfg.image.name}-modified.img" {
      nativeBuildInputs = [
        squashfsTools
      ];
    } ''
      echo "→ Extracting Anbox root image..."
      unsquashfs -dest rootfs ${cfg.image}

      echo "→ Modifying Anbox root image..."
      (
      cd rootfs
      ${cfg.imageModifications}
      )

      echo "→ Packing modified Anbox root image..."
      mksquashfs rootfs $out -comp xz -no-xattrs -all-root
    ''
  ) { });

in

{

  options.virtualisation.anbox = {

    enable = mkEnableOption "Anbox";

    image = mkOption {
      default = pkgs.anbox.image;
      example = literalExample "pkgs.anbox.image";
      type = types.package;
      description = ''
        Base android image for Anbox.
      '';
    };

    imageModifications = mkOption {
      default = "";
      type = types.lines;
      description = ''
        Commands to edit the image filesystem.

        This can be used to e.g. bundle a privileged F-Droid.

        Commands are ran with PWD being at the root of the filesystem.
      '';
    };

    extraInit = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Extra shell commands to be run inside the container image during init.
      '';
    };

    ipv4 = {
      container = addrOpts 4 "192.168.250.2" 24 "Container";
      gateway = addrOpts 4 "192.168.250.1" 24 "Host";

      dns = mkOption {
        default = "1.1.1.1";
        type = types.str;
        description = ''
          Container DNS server.
        '';
      };
    };
  };

  config = mkIf cfg.enable {

    assertions = singleton {
      assertion = kernelPackages.kernelAtLeast "4.18";
      message = "Anbox needs user namespace support to work properly";
    };

    environment.systemPackages = with pkgs; [ anbox ];

    # Mainline ashmem/binder drivers not available as modules
    boot.kernelModules = optionals useAnboxModules [ "ashmem_linux" "binder_linux" ];
    boot.extraModulePackages = optional useAnboxModules kernelPackages.anbox;

    system.requiredKernelConfig = with config.lib.kernelConfig; mkIf (kernel.kernelOlder "5.5") [
      (isEnabled "ASHMEM")
      (isEnabled "ANDROID")
      (isEnabled "ANDROID_BINDER_IPC")
      (isEnabled "ANDROID_BINDERFS")
      # It is currently impossible to check for this with `lib.kernelConfig`.
      # Though the default is fine:
      # https://github.com/torvalds/linux/blob/f88cd3fb9df228e5ce4e13ec3dbad671ddb2146e/drivers/android/Kconfig#L35-L45
      # ANDROID_BINDER_DEVICES binder,hwbinder,vndbinder
    ];


    virtualisation.lxc.enable = true;
    networking.bridges.anbox0.interfaces = [];
    networking.interfaces.anbox0.ipv4.addresses = [ cfg.ipv4.gateway ];

    networking.nat = {
      enable = true;
      internalInterfaces = [ "anbox0" ];
    };

    # Ensures NetworkManager doesn't touch anbox0
    networking.networkmanager.unmanaged = [
      "anbox0"
    ];

    fileSystems = {
      # mount -t binder none /dev/binderfs/
      "/dev/binderfs" = {
        device = "none";
        fsType = "binder";
        # `nofail` is used here since if the user enables anbox on a system
        # without binderfs enabled in the kernel, we do not want the system to
        # crash and burn.
        options = [ "nofail" ];
      };
    };

    systemd.services.anbox-container-manager = let
      anboxloc = "/var/lib/anbox";
    in {
      description = "Anbox Container Management Daemon";

      environment.XDG_RUNTIME_DIR="${anboxloc}";

      wantedBy = [ "multi-user.target" ];
      preStart = let
        initsh = pkgs.writeText "nixos-init" (''
          #!/system/bin/sh
          setprop nixos.version ${config.system.nixos.version}

          # we don't have radio
          setprop ro.radio.noril yes
          stop ril-daemon

          # speed up boot
          setprop debug.sf.nobootanimation 1
        '' + cfg.extraInit);
        initshloc = "${anboxloc}/rootfs-overlay/system/etc/init.goldfish.sh";
      in ''
        mkdir -p ${anboxloc}
        mkdir -p $(dirname ${initshloc})
        [ -f ${initshloc} ] && rm ${initshloc}
        cp ${initsh} ${initshloc}
        chown 100000:100000 ${initshloc}
        chmod +x ${initshloc}
      '';

      serviceConfig = {
        ExecStart = ''
          ${pkgs.anbox}/bin/anbox container-manager \
            --data-path=${anboxloc} \
            --android-image=${finalImage} \
            --container-network-address=${cfg.ipv4.container.address} \
            --container-network-gateway=${cfg.ipv4.gateway.address} \
            --container-network-dns-servers=${cfg.ipv4.dns} \
            --use-rootfs-overlay \
            --privileged
        '';
      };
    };
  };

}
