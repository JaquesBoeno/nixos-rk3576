{ pkgs, ... }:

{
  networking.hostName = "rock-4d";

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  # Allow your user to access the RKNPU device (/dev/rknpu, /dev/dri/renderD*)
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "render"
      "video"
    ];
  };

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    git
    htop
    pciutils
    usbutils
  ];

  system.stateVersion = "24.11";
}
