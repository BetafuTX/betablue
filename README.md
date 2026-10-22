<img width="2048" height="2048" alt="blueb" src="https://github.com/user-attachments/assets/0f2beafd-a0c2-411d-9e08-2d8bd5d7c63d" />
# bazzite-niri

[Bazzite](https://github.com/ublue-os/bazzite) with the [niri](https://github.com/niri-wm/niri) scrolling-tiling compositor and [Dank Material Shell](https://duxlabs.dev) (now called **Dux Shell**; package name `dms`) pre-installed, built with [BlueBuild](https://blue-build.org).

Everything Bazzite ships is untouched — KDE Plasma, Gaming Mode, drivers, kernel, `ujust`. niri is added as an extra session you can pick at the login screen, with DMS providing the bar, launcher, notifications, lock screen and theming.

| Image | Base | For |
|---|---|---|
| `ghcr.io/<you>/bazzite-niri` | `ghcr.io/ublue-os/bazzite:stable` | AMD / Intel GPUs |
| `ghcr.io/<you>/bazzite-niri-nvidia` | `ghcr.io/ublue-os/bazzite-nvidia:stable` | NVIDIA GPUs (proprietary driver) |

## How this relates to "forking Bazzite"

This repo does **not** clone Bazzite's source and rebuild it. It layers on top of Bazzite's published image (`base-image:` in each recipe), so every upstream Bazzite update arrives automatically on the next daily build and you only maintain the niri/DMS delta. This is the approach BlueBuild is designed for and is far less work than keeping a true fork of Bazzite's Containerfiles in sync.

## What gets added

- **niri** + **xwayland-satellite** (from the `duxlabs/dux` COPR)
- **dms** (Dank Material Shell / Dux Shell, stable channel, `duxlabs/dms` COPR) + **quickshell**
- DMS companions: matugen, dgop, dsearch, cliphist, cava, qt6-qtmultimedia, i2c-tools, brightnessctl, wl-clipboard
- niri session plumbing: xdg-desktop-portal-gnome / -gtk, gnome-keyring
- alacritty + fuzzel so niri's stock keybinds (Mod+T, Mod+D) work before any setup
- waybar, mako, swaylock and swayidle are **excluded** — DMS replaces them
- A `niri.service` drop-in so DMS starts with niri and *only* with niri (not in Plasma or Gaming Mode)
- `ujust` helpers: `setup-niri-dms`, `niri-dms-doctor`, `disable-dms-autostart`, `enable-dms-autostart`

## Repository layout

```
recipes/
  recipe.yml            # bazzite-niri        (FROM bazzite:stable)
  recipe-nvidia.yml     # bazzite-niri-nvidia (FROM bazzite-nvidia:stable)
  common/niri-dms.yml   # shared modules: COPRs, packages, files
files/system/
  usr/lib/systemd/user/niri.service.d/10-dms.conf   # auto-start DMS with niri
  usr/share/ublue-os/just/60-custom.just            # ujust recipes
.github/workflows/build.yml                         # daily build of both images
```

## Setup (one time)

1. Create a new GitHub repo from this folder (or from [blue-build/template](https://github.com/blue-build/template) and copy these files over).
2. Generate a signing key — run this **without** a password:
   ```bash
   cosign generate-key-pair
   ```
   Commit `cosign.pub` to the repo root. Add the contents of `cosign.key` as a repository secret named `SIGNING_SECRET` (Settings → Secrets and variables → Actions). Never commit `cosign.key`.
3. Make sure Actions are enabled, then run the **bluebuild** workflow (Actions tab → Run workflow) or just push.
4. After the first build, set both packages to **public** under your profile's Packages tab so machines can pull them without logging in.

## Installing

From any existing Bazzite (or other Fedora Atomic) install — first unsigned, to pick up your signing policy, then signed:

```bash
# AMD/Intel — use bazzite-niri-nvidia for NVIDIA
rpm-ostree rebase ostree-unverified-registry:ghcr.io/<you>/bazzite-niri:latest
systemctl reboot

rpm-ostree rebase ostree-image-signed:docker://ghcr.io/<you>/bazzite-niri:latest
systemctl reboot
```

For a fresh install from USB, see BlueBuild's [ISO guide](https://blue-build.org/how-to/generate-iso/).

**Secure Boot:** nothing here adds kernel modules, so Bazzite's key (`ujust enroll-secure-boot-key`, password `universalblue`) still covers everything.

## First login to niri

1. At the SDDM login screen pick **Niri** from the session menu and log in. The DMS bar starts automatically.
2. Run `ujust setup-niri-dms` once. It backs up any existing `~/.config/niri/config.kdl` and runs `dms setup`, which writes a niri config with DMS keybinds, layout and theme integration.
3. Log out and back in (or restart niri). Plasma remains available from the same session menu, and Gaming Mode is unchanged.

Until step 2, niri uses its built-in default config: Mod+T opens alacritty, Mod+D opens fuzzel, Mod+Shift+/ shows the keybind list. That default config tries to launch waybar; since it isn't installed, the line is harmless — `dms setup` replaces it anyway.

## Customising

- **Development builds of DMS:** in `recipes/common/niri-dms.yml`, change `duxlabs/dms` to `duxlabs/dms-git` and `dms` to `dms-git`.
- **Other Bazzite variants:** copy `recipe.yml`, change `base-image` (e.g. `ghcr.io/ublue-os/bazzite-gnome`, `bazzite-gnome-nvidia`) and `name`, then add the file to the workflow matrix. `bazzite-deck` variants boot straight to Gaming Mode, so niri is only reachable via "Switch to Desktop" session settings there.
- **Dux Greeter:** DMS also offers a greetd login screen (`dms-greeter`). It isn't included because replacing Bazzite's SDDM affects the Gaming Mode/desktop switching; add it only if you know you want it.

## Build locally

```bash
bluebuild build recipes/recipe.yml
```

See [How to build and test locally](https://blue-build.org/how-to/local/).
