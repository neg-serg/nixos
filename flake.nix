{
    description = "Neg-Serg configuration";
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    };
    outputs = { self, nixpkgs, chaotic, ... }@inputs: {
        nixosConfigurations = {
            hostname = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    ./configuration.nix # Your system configuration.
                    chaotic.nixosModules.default # OUR DEFAULT MODULE
                ];
                specialArgs.inputs = inputs;
            };
        };
    };
}
