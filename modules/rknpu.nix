{ config, lib, ... }:

let
  cfg = config.hardware.rk3576.rknpu;
in
{
  key = "nixos-rk3576-rknpu";

  options.hardware.rk3576.rknpu = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable udev rules and group permissions for Rockchip RK3576 NPU (RKNPU).";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "render";
      description = "System group granted read/write access to RKNPU device nodes.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.${cfg.group} = { };

    services.udev.extraRules = ''
      # Allow non-root users in the configured group to access the Rockchip NPU
      KERNEL=="rknpu", GROUP="${cfg.group}", MODE="0660"
      SUBSYSTEM=="misc", KERNEL=="rknpu", GROUP="${cfg.group}", MODE="0660"
      SUBSYSTEM=="drm", KERNEL=="renderD*", GROUP="${cfg.group}", MODE="0660"
    '';
  };
}
