self:
{ pkgs, lib, ... }:

{
  key = "nixos-rk3576-kernel";

  # Use the kernelPackages pre-built against this flake's pinned nixpkgs so
  # downstream consumers get 100% binary cache hits even when their own system
  # uses a different nixpkgs revision.
  boot.kernelPackages = lib.mkDefault self.legacyPackages.${pkgs.stdenv.hostPlatform.system}.linuxPackages_rk3576;

  boot.kernelParams = [
    "console=ttyFIQ0,1500000n8"
    "console=tty1"
    "earlycon"
  ];

  # Avoid NixOS's default initrd module list, which references mainline module
  # names that may not exist or have different names in Rockchip's 6.1 BSP tree.
  boot.initrd.includeDefaultModules = lib.mkDefault false;
  boot.initrd.availableKernelModules = lib.mkDefault [
    "nvme"
    "mmc_block"
    "sdhci_of_dwcmshc"
    "dw_mmc_rockchip"
    "usb_storage"
    "xhci_hcd"
    "ext4"
    "btrfs"
    "dm_mod"
  ];
}
