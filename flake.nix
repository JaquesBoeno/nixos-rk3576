{
  description = "Public NixOS flake for Rockchip RK3576 (Radxa ROCK 4D) vendor Linux 6.1 kernel with RKNPU support";

  nixConfig = {
    extra-substituters = [
      "https://nixos-rk3576.cachix.org"
    ];
    extra-trusted-public-keys = [
      # Replace with your Cachix public key after creating the cache:
      # `cachix create nixos-rk3576` -> copy public key here
      "nixos-rk3576.cachix.org-1:MnQ78NQniiiZE49zIYvOuFnKUcxvXq+FbyTGeVcw+HA="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    radxa-kernel = {
      url = "git+https://github.com/radxa/kernel?ref=linux-6.1-stan-rkr4.1-buildroot&shallow=1";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      radxa-kernel,
      ...
    }:
    let
      system = "aarch64-linux";
      pkgs = import nixpkgs { inherit system; };
      kernel = pkgs.callPackage ./pkgs/kernel-rk3576 { inherit radxa-kernel; };
      linuxPackages = pkgs.linuxPackagesFor kernel;
    in
    {
      packages.${system} = {
        inherit kernel;
        default = kernel;
      };

      legacyPackages.${system} = {
        linux_rk3576 = kernel;
        linuxPackages_rk3576 = linuxPackages;
      };

      overlays.default =
        final: _prev:
        let
          k = final.callPackage ./pkgs/kernel-rk3576 { inherit radxa-kernel; };
        in
        {
          linux_rk3576 = k;
          linuxPackages_rk3576 = final.linuxPackagesFor k;
        };

      nixosModules = {
        kernel = import ./modules/kernel.nix self;
        rknpu = ./modules/rknpu.nix;
        rock-4d = import ./modules/boards/rock-4d.nix self;
        default = self.nixosModules.rock-4d;
      };

      templates = {
        rock-4d = {
          path = ./templates/rock-4d;
          description = "Minimal NixOS configuration for Radxa ROCK 4D (RK3576) using vendor kernel and RKNPU";
        };
        default = self.templates.rock-4d;
      };
    };
}
