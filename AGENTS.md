# AGENTS.md

## Cursor Cloud specific instructions

This repo is a **Nix flake** that builds a NixOS system for a **Raspberry Pi 4
(`aarch64-linux`)**. There is no long-running app to serve; "running the
application" means building the NixOS system configuration (`toplevel`) and,
optionally, the SD-card image. See `README.md` and `.github/workflows/ci.yaml`
for the canonical build targets.

### Key fact: cross-architecture builds

The cloud VM is `x86_64-linux`, but every flake output targets `aarch64-linux`.
Builds therefore rely on `aarch64` emulation via QEMU + `binfmt_misc`. QEMU
(`/usr/bin/qemu-aarch64-static`) is installed in the VM snapshot, and the update
script re-registers the `binfmt_misc` interpreter on each boot (that registration
is runtime state and does not survive a reboot).

### Session start: start the Nix daemon (required, not in update script)

Nix is installed multi-user with **no init system**, so the daemon is not started
automatically. Start it once per session before running any `nix` command:

```bash
# daemon (background service — leave it running)
[ -S /nix/var/nix/daemon-socket/socket ] || sudo /nix/var/nix/profiles/default/bin/nix-daemon &
```

A convenient way to keep it alive is a dedicated tmux session:
`tmux new-session -d -s nix-daemon -- sudo /nix/var/nix/profiles/default/bin/nix-daemon`.

Login shells already source `/etc/profile.d/nix.sh`, so `nix` is on `PATH`
automatically in new shells. Flakes and `nix-command` are enabled globally.

### aarch64 emulation (handled by the update script, but here for reference)

If `nix build` fails with an "Exec format error" for `aarch64` builds, the
`binfmt_misc` registration is missing. Re-run:

```bash
sudo mountpoint -q /proc/sys/fs/binfmt_misc || sudo mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc
echo ':qemu-aarch64:M::\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/bin/qemu-aarch64-static:OCF' | sudo tee /proc/sys/fs/binfmt_misc/register
```

The `F` (fix-binary) flag is important: it makes emulation work inside the Nix
build sandbox.

### Binary caches

`/etc/nix/nix.custom.conf` adds `aarch64-linux` to `extra-platforms` and trusts
the `nixos-raspberrypi.cachix.org` substituter (matching the flake's `nixConfig`).
The flake's own `nixConfig` substituters are ignored unless you pass
`--accept-flake-config`; the system config already covers them, so this warning
is harmless.

### Lint / check / build commands

- Evaluate + lint the whole flake (fast, no full builds):
  `nix flake check --all-systems`
- Build the NixOS system (the primary CI target):
  `nix build .#nixosConfigurations.rpi.config.system.build.toplevel`
- Build the bootable SD image (heavy; large disk + long emulated build):
  `nix build .#rpi4-image`

### Gotchas

- `home-assistant` is pulled from `nixpkgs-unstable` with a `paho-mqtt`
  `doCheck = false` overlay (`overlays/paho-mqtt.nix`). This changes its closure
  hash, so it is **not in any binary cache and is rebuilt from source under
  emulation** on the first `toplevel` build (slow, but mostly file-copying, not
  compilation). Subsequent builds hit the local `/nix/store`.
- Vendor `linux_rpi` comes from `nixos-raspberrypi.cachix.org`, not
  `cache.nixos.org`. Keep the flake input on a pin that still has the kernel
  in that cache (stale `nixos-26.05` pins age out). Do not re-enable
  `boot.supportedFilesystems.zfs` unless you need it: `sd-image`/`profiles.base`
  defaults it on for aarch64 and that pulls an uncached `zfs-kernel` build.
- Do not commit the `result` symlink created by `nix build`.
