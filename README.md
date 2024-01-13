# jmglov's NixOS config

I use this config to manage my two NixOS laptops. If you find anything useful
here, help yourself with my compliments! 😀

## Installing NixOS

### Creating minimal installer USB

On Linux:

``` text
NIXOS_VERSION=23.11
cd ~/Downloads
wget https://channels.nixos.org/nixos-${NIXOS_VERSION}/latest-nixos-minimal-x86_64-linux.iso
sudo dd if=nixos-minimal-22.05.2889.67e45078141-x86_64-linux.iso of=/dev/sdb bs=4M conv=fsync
```

### Installing with encrypted root

From https://gist.github.com/martijnvermaat/76f2e24d0239470dd71050358b4d5134.

``` text
sudo -i
gdisk /dev/sda
```

- `o` (create new empty partition table)
- `n` (add partition, 500M, type ef00 EFI)
- `n` (add partition, remaining space, type 8300 Linux LVM)
- `w` (write partition table and exit)

``` text
HOSTNAME=whatever
cryptsetup luksFormat /dev/sda2
cryptsetup luksOpen /dev/sda2 enc-pv

VG=vg-$HOSTNAME
pvcreate /dev/mapper/enc-pv
vgcreate $VG /dev/mapper/enc-pv
lvcreate -L 8G -n swap $VG
lvcreate -l '100%FREE' -n root $VG

mkfs.fat /dev/sda1
mkfs.ext4 -L root /dev/$VG/root
mkswap -L swap /dev/$VG/swap

mount /dev/$VG/root /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
swapon /dev/$VG/swap

wpa_passphrase SSID PASSPHRASE >/etc/wpa_supplicant.conf
systemctl start wpa_supplicant

git clone https://github.com/jmglov/nixos-config.git /mnt/etc/nixos
echo '"'$HOSTNAME'"' > /mnt/etc/nixos/hostname.nix
nixos-generate-config --root /mnt
nixos-install

reboot
```

## Upgrading NixOS

``` text
sudo nix-channel --add https://nixos.org/channels/nixos-23.11 nixos  # or latest version
sudo nix-channel --update
sudo nixos-rebuild boot --upgrade
```

Then reboot to complete the upgrade.

### Troubleshooting

Sometimes there can be changes that require new kernel params or some such. If
you get an odd error similar to this one:

``` text
× systemd-backlight@leds:dell::kbd_backlight.service - Load/Save Screen Backlight Brightness of leds:dell::kbd_backlight
     Loaded: loaded (/etc/systemd/system/systemd-backlight@.service; static)
    Drop-In: /nix/store/2iz1crfvdigal54kblzhrdaic0nl37jy-system-units/systemd-backlight@.service.d
             └─overrides.conf
     Active: failed (Result: exit-code) since Tue 2024-01-09 17:52:05 CET; 2s ago
       Docs: man:systemd-backlight@.service(8)
    Process: 2961690 ExecStart=/nix/store/i0sdqs34r68if9s4sfmpixnnj36npiwj-systemd-254.6/lib/systemd/systemd-backlight load leds:dell::kbd_backlight (code=exited, status=
1/FAILURE)
   Main PID: 2961690 (code=exited, status=1/FAILURE)
         IP: 0B in, 0B out
        CPU: 13ms

Jan 09 17:52:05 laurana systemd[1]: Starting Load/Save Screen Backlight Brightness of leds:dell::kbd_backlight...
Jan 09 17:52:05 laurana systemd-backlight[2961690]: dell::kbd_backlight: Failed to read current brightness: Invalid argument
Jan 09 17:52:05 laurana systemd[1]: systemd-backlight@leds:dell::kbd_backlight.service: Main process exited, code=exited, status=1/FAILURE
Jan 09 17:52:05 laurana systemd[1]: systemd-backlight@leds:dell::kbd_backlight.service: Failed with result 'exit-code'.
Jan 09 17:52:05 laurana systemd[1]: Failed to start Load/Save Screen Backlight Brightness of leds:dell::kbd_backlight.
warning: error(s) occurred while switching to the new configuration
```

Try regenerating the hardware config and then rebuilding again:

``` text
sudo nixos-generate-config
sudo nixos-rebuild switch --upgrade
```

## Rescuing NixOS

Boot off NixOS installer USB stick, then:

``` text
sudo -i

# Find HDD device
lsblk
# => NAME          MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
#    loop0           7:0    0 787.3M  1 loop  /nix/.ro-store
#    sda             8:0    1   7.2G  0 disk
#    ├─sda1          8:1    1   820M  0 part  /iso
#    └─sda2          8:2    1     3G  0 part
#    nvme0n1       259:0    0 476.9G  0 disk
#    ├─nvme0n1p1   259:1    0   500M  0 part
#    └─nvme0n1p2   259:2    0 476.5G  0 part

LUKS_DEV=nvme0n1p2
cryptsetup luksOpen /dev/$HDD_DEV enc-pv
```

### Renaming an LVM group

I originally created the LVM group as `vg` on both of my laptops, but this makes
it tricky to mount one drive on the other laptop in case of needing to back it
up (don't ask me how I found this out). I decided instead to rename the vg
`vg-{hostname}`:

``` text
HOSTNAME=alhana
BOOT_DEV=nvme0n1p1

# Find VG UUID
vgdisplay
# =>   --- Volume group ---
#      VG Name               vg
#      System ID
#      Format                lvm2
#      Metadata Areas        1
#      Metadata Sequence No  3
#      VG Access             read/write
#      VG Status             resizable
#      MAX LV                0
#      Cur LV                2
#      Open LV               2
#      Max PV                0
#      Cur PV                1
#      Act PV                1
#      VG Size               <893.75 GiB
#      PE Size               4.00 MiB
#      Total PE              228799
#      Alloc PE / Size       228799 / <893.75 GiB
#      Free  PE / Size       0 / 0
#      VG UUID               w7qJ3f-invQ-Jz43-PZhY-pRYr-607I-Epc8rt

VG_UUID=$(vgdisplay | tail -n 2 | head -n 1 | awk '{ print $3 }')
lvm vgrename $VG_UUID vg-$HOSTNAME

mount /dev/vg-$HOSTNAME/root /mnt
mount /dev/$BOOT_DEV /mnt/boot
swapon /dev/vg-$HOSTNAME/swap

wpa_passphrase SSID PASSPHRASE >/etc/wpa_supplicant.conf
systemctl start wpa_supplicant
nixos-generate-config --root /mnt
nix-enter
nixos-rebuild --install-bootloader boot
```
