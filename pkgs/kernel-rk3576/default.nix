{
  lib,
  buildLinux,
  radxa-kernel,
  ...
}@args:

let
  # Keep version/modDirVersion aligned with the root Makefile of radxa/kernel.
  # Override via `override` if bumping to a newer rkr tag with a different sublevel.
  version = "6.1.84";
in
buildLinux (
  args
  // {
    inherit version;
    modDirVersion = version;

    src = radxa-kernel;

    defconfig = "rockchip_linux_defconfig";

    # Vendor BSP trees ship monolithic configs and custom out-of-tree drivers;
    # these flags prevent Nixpkgs' generate-config.pl from failing on unused or
    # vendor-renamed symbols.
    autoModules = false;
    ignoreConfigErrors = true;

    structuredExtraConfig = import ./config.nix { inherit lib; };

    kernelPatches = [ ];

    extraMeta = {
      description = "Rockchip RK3576 vendor Linux 6.1 kernel (Radxa BSP) with RKNPU support";
      homepage = "https://github.com/radxa/kernel";
      platforms = [ "aarch64-linux" ];
    };
  }
  // (args.argsOverride or { })
)
