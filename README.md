# nixos-rk3576

Flake pública do NixOS para compilar e distribuir o **kernel vendor Rockchip RK3576 (Linux 6.1 BSP da Radxa)** com suporte à **NPU (RKNPU)** para placas como a **Radxa ROCK 4D**, incluindo módulos reutilizáveis e cache binário via Cachix.

## Recursos

- **Kernel Vendor (`packages.aarch64-linux.kernel`):** baseado em [`radxa/kernel`](https://github.com/radxa/kernel) (branch `linux-6.1-stan-rkr4.1-buildroot`) empacotado com `pkgs.buildLinux`.
- **Suporte à NPU (`ROCKCHIP_RKNPU` + `DEBUG_FS`):** driver RKNPU habilitado no kernel e regras `udev` prontas (`modules/rknpu.nix`) para acesso sem `root` via grupo `render`.
- **Módulo pronto para Radxa ROCK 4D (`nixosModules.rock-4d`):** configura `rk3576-rock-4d.dtb`, `extlinux.conf` para U-Boot, parâmetros seriais e lista de módulos de `initrd` compatível com o kernel BSP.
- **Cache Hit garantido:** o módulo `nixosModules.kernel` usa o kernel pré-construído com o `nixpkgs` pinado desta flake, evitando recompilação local mesmo se o seu sistema usar outra revisão do `nixpkgs`.

---

## Como usar no seu NixOS

### 1. Usando o template inicial

```bash
nix flake init -t github:JaquesBoeno/nixos-rk3576#rock-4d
```

### 2. Adicionando manualmente na sua `flake.nix`

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # IMPORTANTE: não faça `rk3576.inputs.nixpkgs.follows = "nixpkgs";`
    # se você quiser aproveitar o cache binário sem recompilar o kernel localmente.
    rk3576.url = "github:JaquesBoeno/nixos-rk3576";
  };

  outputs = { nixpkgs, rk3576, ... }: {
    nixosConfigurations.rock-4d = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        rk3576.nixosModules.rock-4d
        ./configuration.nix
      ];
    };
  };
}
```

### 3. Configurando o Cache Binário (Cachix)

Adicione o substituter no seu `/etc/nixos/configuration.nix` (ou aceite o `nixConfig` da flake):

```nix
nix.settings = {
  extra-substituters = [ "https://nixos-rk3576.cachix.org" ];
  extra-trusted-public-keys = [
    "nixos-rk3576.cachix.org-1:MnQ78NQniiiZE49zIYvOuFnKUcxvXq+FbyTGeVcw+HA="
  ];
};
```

> **Nota para quem for publicar um fork/repositório:**
> 1. Crie seu cache no Cachix (`cachix create nixos-rk3576`).
> 2. Atualize a chave pública em `flake.nix` (`nixConfig.extra-trusted-public-keys`) e neste `README.md`.
> 3. Adicione o secret `CACHIX_AUTH_TOKEN` nas configurações do GitHub Actions do repositório.
> 4. Atualize `YOUR_USER` / `SEU_USUARIO` em `templates/rock-4d/flake.nix` e no `README.md`.

---

## Validação na Radxa ROCK 4D

Após dar boot com U-Boot compatível carregando o `/boot/extlinux/extlinux.conf` gerado pelo NixOS:

```bash
# Confirmar kernel vendor 6.1
uname -a

# Verificar driver RKNPU no dmesg e debugfs
dmesg | grep -i rknpu
cat /sys/kernel/debug/rknpu/version
cat /sys/kernel/debug/rknpu/load

# Verificar permissões do dispositivo para usuários no grupo `render`
ls -l /dev/rknpu /dev/dri/renderD*
```

---

## Estrutura do Repositório

```text
nixos-rk3576/
├── flake.nix
├── README.md
├── pkgs/
│   └── kernel-rk3576/
│       ├── default.nix            # Derivação buildLinux
│       ├── config.nix             # structuredExtraConfig (systemd + NixOS + RKNPU)
│       └── patches/               # Patches extras (.patch)
├── modules/
│   ├── kernel.nix                 # boot.kernelPackages + kernelParams + initrd
│   ├── rknpu.nix                  # Regras udev e grupo para acesso à NPU
│   └── boards/
│       └── rock-4d.nix            # DTB, extlinux e firmware da Radxa ROCK 4D
├── templates/
│   └── rock-4d/                   # Template mínimo para novos usuários
└── .github/
    └── workflows/
        └── build-and-cache.yml    # CI nativo ARM64 (ubuntu-24.04-arm) -> Cachix
```

## Uso avançado: Overlay

Se você precisar recompilar o kernel contra o seu próprio `nixpkgs` (por exemplo, para aplicar patches locais ou módulos out-of-tree específicos), use `rk3576.overlays.default` em vez de `nixosModules.kernel`. Isso disponibilizará `pkgs.linux_rk3576` e `pkgs.linuxPackages_rk3576`.
