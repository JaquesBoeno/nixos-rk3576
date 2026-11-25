self:
{ lib, ... }:

{
  key = "nixos-rk3576-rock-4d";

  imports = [
    (import ../kernel.nix self)
    ../rknpu.nix
  ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  hardware.deviceTree.name = lib.mkDefault "rockchip/rk3576-rock-4d.dtb";
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  # Radxa ROCK 4D boots via U-Boot using extlinux.conf
  boot.loader.grub.enable = lib.mkDefault false;
  boot.loader.generic-extlinux-compatible.enable = lib.mkDefault true;
}
