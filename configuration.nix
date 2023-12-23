# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, lib, pkgs, modulesPath, packageOverrides, ... }:
{
    imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
        ./boot.nix
        ./filesystems.nix
        ./locale.nix
        ./networking.nix
        ./nvidia.nix
        ./udev-rules.nix
        ./python-lto.nix
        ./session.nix
        #./kmscon.nix
    ];
    nix.extraOptions = ''experimental-features = nix-command flakes'';
    nixpkgs.config.allowUnfree = true;

    systemd.packages = [pkgs.packagekit];
    services.pcscd.enable = true;
    services.gvfs.enable = true;
    services.udisks2.enable = true;
    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;
    systemd.services.keyd = {
        description = "key remapping daemon";
        requires = ["local-fs.target"];
        after = ["local-fs.target"];
        serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.keyd}/bin/keyd";
        };
        wantedBy = ["sysinit.target"];
    };

    environment.etc."keyd/keyd.conf".text = lib.mkForce ''
        [ids]
        *

        [main]
        capslock = layer(capslock)

        [capslock:C]
        0 = M-0
        h = left
        j = down
        k = up
        l = right
        2 = down
        3 = up
        [ = escape
        ] = insert
        q = escape
        '';

    security.polkit.enable = true;
    security.sudo.extraRules= [ {
        users = [ "privileged_user" ];
            # "SETENV" # Adding the following could be a good idea
            commands=[{command="ALL" ; options= ["NOPASSWD"];}];
        }
    ];
    security.pam = {
        services.lightdm.enableGnomeKeyring = true;
        loginLimits = [{domain = "@users"; item = "rtprio"; type = "-"; value = 1;}];
    };

    # This is using a rec (recursive) expression to set and access XDG_BIN_HOME within the expression
    # For more on rec expressions see https://nix.dev/tutorials/first-steps/nix-language#recursive-attribute-set-rec
    environment.sessionVariables = rec {
        XDG_CACHE_HOME = "$HOME/.cache";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_STATE_HOME = "$HOME/.local/state";
        XDG_BIN_HOME = "$HOME/.local/bin";
        PATH = ["${XDG_BIN_HOME}"];
        ZDOTDIR = "$HOME/.config/zsh";
    };

    fonts.packages = with pkgs; [];

    hardware.pulseaudio.enable = false;
    hardware.bluetooth.enable = true;
    powerManagement.cpuFreqGovernor = "performance";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    # Enable the OpenRazer driver for my Razer stuff
    hardware.openrazer.enable = true;
    security.rtkit.enable = true; # rtkit is optional but recommended
        services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
            jack.enable = true;
        };

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.neg = {
        packages = with pkgs; [pam_u2f python3-lto];
        isNormalUser = true;
        description = "Neg";
        extraGroups = [
            "audio"
            "neg"
            "networkmanager"
            "systemd-journal"
            "video"
            "openrazer"
            "wheel"
            "tty"
            "input"
        ];
    };

    users.defaultUserShell = pkgs.zsh;
    users.groups.neg.gid = 1000;
    environment.systemPackages = with pkgs; [
        flat-remix-gtk
        flat-remix-icon-theme
        bibata-cursors

        curl
        wget

        gcc
        gdb

        expect

        git
        git-extras

        delta
        exa
        fd
        file

        neovim

        nix-du # nix-du --root /run/current-system/sw/ -s 500MB > result.dot
        nix-index
        nix-update
        nix-output-monitor
        nvd

        abduco
        ripgrep
        tig
        tmux
        zsh

        htop
        iotop
        btop

        terminus-nerdfont

        keyd

        pass-secret-service

        linuxKernel.packages.linux_6_6.perf

        gnomeExtensions.appindicator
        gnome.gnome-settings-daemon
    ];

    # Boot optimizations regarding filesystem:
    # Journald was taking too long to copy from runtime memory to disk at boot
    # set storage to "auto" if you're trying to troubleshoot a boot issue
    services.journald.extraConfig = ''
        Storage=auto
        SystemMaxFileSize=300M
        SystemMaxFiles=50
    '';

    environment.shells = with pkgs; [zsh];

    programs = {
        # dconf = { enable = true; };
        mtr = { enable = true; };
        zsh = { enable = true; };
    };

    services = {
        flatpak.enable = true;
        openssh.enable = true;
        udev.packages = with pkgs; [gnome.gnome-settings-daemon yubikey-personalization];
    };

    xdg.portal = {
        enable = true;
        extraPortals = [pkgs.xdg-desktop-portal-gtk];
        config.common.default = "gtk";
    };

    # (man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.11"; # Did you read the comment?
    system.copySystemConfiguration = true;
    system.autoUpgrade.enable = true;
    system.autoUpgrade.allowReboot = true;
}
