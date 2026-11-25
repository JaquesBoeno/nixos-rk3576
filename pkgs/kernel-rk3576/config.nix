{ lib }:

with lib.kernel;

{
  # --- RKNPU (Rockchip Neural Processing Unit) ---
  ROCKCHIP_RKNPU = yes;
  DEBUG_FS = yes;

  # --- NixOS & systemd mandatory requirements ---
  # Disable BTF to avoid compiling Linux 6.1's bundled tools/bpf/resolve_btfids
  # against newer glibc/uapi headers on nixos-unstable.
  DEBUG_INFO_BTF = lib.mkForce no;
  DEVTMPFS = yes;
  DEVTMPFS_MOUNT = yes;
  CGROUPS = yes;
  CGROUP_SCHED = yes;
  CGROUP_PIDS = yes;
  CGROUP_FREEZER = yes;
  CGROUP_DEVICE = yes;
  CGROUP_CPUACCT = yes;
  CGROUP_BPF = yes;
  BPF_SYSCALL = yes;
  IKCONFIG = yes;
  IKCONFIG_PROC = yes;
  AUTOFS_FS = yes;
  OVERLAY_FS = module;
  SQUASHFS = module;
  ZRAM = module;
  TMPFS_POSIX_ACL = yes;
  FHANDLE = yes;
  SECCOMP = yes;
  EPOLL = yes;
  SIGNALFD = yes;
  TIMERFD = yes;
  INOTIFY_USER = yes;
  NAMESPACES = yes;
  USER_NS = yes;
  NET_NS = yes;
  PID_NS = yes;

  # --- Networking & Firewall (nftables / iptables) ---
  NETFILTER = yes;
  NF_TABLES = module;
  NF_CONNTRACK = module;
  NETFILTER_XTABLES = module;

  # --- Storage, PCIe & USB for Radxa ROCK 4D (RK3576) ---
  NVME_CORE = module;
  BLK_DEV_NVME = module;
  PCIE_DW_ROCKCHIP = yes;
  MMC_DW = yes;
  MMC_DW_ROCKCHIP = yes;
  MMC_SDHCI = yes;
  MMC_SDHCI_PLTFM = yes;
  MMC_SDHCI_OF_DWCMSHC = yes;
  USB_XHCI_HCD = yes;
  USB_DWC3 = yes;
  USB_DWC3_OF_SIMPLE = yes;

  # --- Ethernet ---
  STMMAC_ETH = yes;
  STMMAC_PLATFORM = yes;
  DWMAC_ROCKCHIP = yes;
}
