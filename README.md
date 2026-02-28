# Neovim Kickstart Config

This repo contains my custom Neovim configuration, built on top of [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim). It’s a clean, modern setup with LSP support, autocompletion, formatting, and sensible defaults for day‑to‑day development.

> [!IMPORTANT]
> This config targets Neovim 0.11+. If you’re on Neovim 0.10.x, use the legacy setup on the `v0.10.1` branch.

## Install

```bash
# Backup if you already have a config
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null

# Clone this repo as your Neovim config
git clone <REPO_URL> ~/.config/nvim
```

Then open Neovim:

```bash
nvim
```

## Remote editing via SSHFS

This workflow mounts a remote directory into a local folder using SSHFS, then you edit the mounted folder with your local Neovim setup. SSHFS syntax is `sshfs [user@]host:[dir] mountpoint [options]`. [man7](https://man7.org/linux/man-pages/man1/sshfs.1.html)

### 1) Mount the remote directory

Create a local mount directory:

```bash
mkdir -p <LOCAL_MOUNT_DIR>
```

Mount remote → local:

```bash
sshfs -o reconnect -p <PORT> <USERNAME>@<HOST>:/path/to/remote <LOCAL_MOUNT_DIR>
```

Notes:

- `<LOCAL_MOUNT_DIR>` must exist and be owned by your user for SSHFS mounts. [man7](https://man7.org/linux/man-pages/man1/sshfs.1.html)
- If you omit the remote `:dir`, SSHFS mounts the remote home directory. [man7](https://man7.org/linux/man-pages/man1/sshfs.1.html)

### 2) Reveal it in Neovim (Neo-tree)

Inside Neovim:

```vim
:Neotree reveal <LOCAL_MOUNT_DIR>
```

To close Neo-tree:

```vim
:Neotree close
```

(Neo-tree supports revealing a specific path/file via its `reveal` / `reveal_file` behaviors.) [github](https://github.com/nvim-neo-tree/neo-tree.nvim)

## Unmount

When you’re done, unmount the SSHFS mount:

```bash
fusermount -uz <LOCAL_MOUNT_DIR>
```

`fusermount -u` is the standard way to unmount SSHFS mounts on Linux. [digitalocean](https://www.digitalocean.com/community/tutorials/how-to-use-sshfs-to-mount-remote-file-systems-over-ssh)

## Example (template)

```bash
mkdir -p ~/mnt/remote-project
sshfs -o reconnect -p 22 user@server:/home/user/project ~/mnt/remote-project
nvim
```

In Neovim:

```vim
:Neotree reveal ~/mnt/remote-project
```

Unmount later:

```bash
fusermount -uz ~/mnt/remote-project
```

[![Full Neovim Setup from Scratch in 2025](https://img.youtube.com/vi/KYDG3AHgYEs/0.jpg)](https://youtu.be/KYDG3AHgYEs?si=I71UjuoQg2fHLGyu)
