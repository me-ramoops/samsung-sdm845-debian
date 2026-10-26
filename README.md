# Debian GNU/Linux ARM64 on Samsung Snapdragon 845

Automated Mainline Linux Kernel & Debian ARM64 image builder for Samsung Galaxy S9, S9+ and Note 9.

## Supported Devices

| Codename | Device | Model | Battery | Display |
| :--- | :--- | :--- | :--- | :--- |
| **`starqltechn`** | Samsung Galaxy S9 | SM-G9600 | 3000 mAh | 2960x1440 AMOLED (S6E3HA8) |
| **`star2qltechn`** | Samsung Galaxy S9+ | SM-G9650 | 3500 mAh | 2960x1440 AMOLED (S6E3HA8) |
| **`crownqltechn`** | Samsung Galaxy Note 9 | SM-N9600 | 4000 mAh | 2960x1440 AMOLED (S6E3HA8) |

## Features & Working Hardware

- **Instant Display (First-Time Boot Guarantee):** Native simple-framebuffer mapped at `0x9d400000` (2960x1440), providing immediate kernel console (`tty0`) on boot without DRM panel blackscreens.
- **USB Ethernet Gadget & SSH:** Automatically initializes NCM USB gadget on `172.16.42.1/24`. Plug into any PC and connect directly via SSH:
  ```bash
  ssh root@172.16.42.1
  # Default password: root
  ```
- **Failsafe Rescue Shell:** If rootfs mounting fails or userdata is missing, the initramfs automatically starts an emergency USB network shell with Telnet listening on `172.16.42.1:23`.
- **WiFi:** Broadcom BCM4375 PCIe RC0 with dedicated `tlmm 99` power sequencing regulator and `brcmfmac`.
- **Storage:** UFS 2.1 (`/dev/sda`) + MicroSD Card (`/dev/mmcblk0`).
- **Touchscreen:** Samsung S6SY761.
- **Power Management:** Maxim MAX77705 MFD (charger, fuelgauge, RGB LED, haptics).

## Flashing Instructions

### 1. Download Artifacts
From the [GitHub Actions Runs](https://github.com/me-ramoops/samsung-sdm845-debian/actions), download:
- `sdm845-boot-images.zip` (contains `<device>-boot.img` and `<device>-boot.tar`)
- `sdm845-debian-rootfs.zip` (contains `debian-sdm845-rootfs.ext4`)

### 2. Flashing the Boot Image

#### Via Samsung Odin (Download Mode):
1. Reboot phone to Download Mode (Power + Bixby + Vol Down).
2. Load `<device>-boot.tar` into Odin's **AP** slot.
3. Flash and reboot.

#### Via Heimdall:
```bash
heimdall flash --BOOT <device>-boot.img
```

#### Via TWRP / Recovery:
```bash
adb push <device>-boot.img /tmp/
adb shell dd if=/tmp/<device>-boot.img of=/dev/block/bootdevice/by-name/boot
```

### 3. Installing the Debian Rootfs

The initramfs automatically looks for a filesystem labeled `debian-root` (or uses `system` / `userdata` / MicroSD card).

#### Option A: Flash to System partition
```bash
adb push debian-sdm845-rootfs.ext4 /tmp/
adb shell dd if=/tmp/debian-sdm845-rootfs.ext4 of=/dev/block/bootdevice/by-name/system bs=4M status=progress
```

#### Option B: Write to MicroSD Card
```bash
sudo dd if=debian-sdm845-rootfs.ext4 of=/dev/sdX bs=4M status=progress
```

### 4. Logging In

Connect your phone to your PC via USB cable.
Configure your PC network adapter:
- **IP:** `172.16.42.2`
- **Netmask:** `255.255.255.0`

Log in via SSH:
```bash
ssh root@172.16.42.1
# Password: root
```

Connect to WiFi:
```bash
nmcli device wifi connect "YOUR_SSID" password "YOUR_PASSWORD"
```

## Credits
- **LineageOS & sdm845-mainline community**
- **Dzmitry Sankouski (`dsankouski`)** for upstream starqltechn bringup & drivers
- **fwlta (`monkeyfwlta@protonmail.com`)**
