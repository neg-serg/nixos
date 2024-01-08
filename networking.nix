{ config, lib, pkgs, modulesPath, ... }:
{
    networking.hostName = "telfir"; # Define your hostname.
    networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.
    networking.networkmanager.enable = true;
    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp6s0.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp8s0.useDHCP = lib.mkDefault true;
    systemd.services = {
        # Unconditionally disable this Removes the time in the startup where the system waits for a connection
        NetworkManager-wait-online.enable = false;
    };
    # networking.search = [(builtins.readFile ./domains)];
    networking.nameservers = [
        "1.1.1.1"
        "172.20.64.1" # OpenVPN defined name servers
        "127.0.0.53" # System defined name servers
    ];
    services.udev.extraRules = ''
        KERNEL=="eth*", ATTR{address}=="fc:34:97:b7:16:0e", NAME="net0"
        KERNEL=="eth*", ATTR{address}=="fc:34:97:b7:16:0f", NAME="net1"
    '';
}
