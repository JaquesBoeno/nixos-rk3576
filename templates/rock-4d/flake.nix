{
  description = "NixOS configuration for Radxa ROCK 4D (RK3576)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # NOTE: Do NOT add `inputs.nixpkgs.follows = "nixpkgs";` here if you want to
    # use the pre-built binary cache for the RK3576 kernel. Overriding nixpkgs
    # changes the kernel derivation hash and forces a full local compile.
    rk3576.url = "github:JaquesBoeno/nixos-rk3576";
  };

  outputs =
    {
      nixpkgs,
      rk3576,
      ...
    }:
    {
      nixosConfigurations.rock-4d = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          rk3576.nixosModules.rock-4d
          ./configuration.nix
        ];
      };
    };
}
