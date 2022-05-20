# ZFS on ARCHLINUX notes

this is just my notes, ive changed some stuff since then  
this uses raid1 mirror with 2 drives and grub. it uses bios and not uefi, however i havent cleaned it up yet, it has some broken mentions of EFI

```bash

# change with your SN

DISK1=/dev/disk/by-id/serial1
DISK2=/dev/disk/by-id/serial2

// boot

zpool create \
    -o compatibility=grub2 \
    -o ashift=12 \
    -o autotrim=on \
    -O acltype=posixacl \
    -O canmount=off \
    -O compression=lz4 \
    -O devices=off \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O mountpoint=/boot \
    -R /mnt \
    bpool mirror ${DISK1}-part2 ${DISK2}-part2

// root
zpool create \
    -o ashift=12 \
    -o autotrim=on \
    -R /mnt \
    -O acltype=posixacl \
    -O canmount=off \
    -O compression=zstd \
    -O dnodesize=auto \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O mountpoint=/ \
    rpool mirror ${DISK1}-part3 ${DISK2}-part3

zfs create -o canmount=off -o mountpoint=none rpool/arch
zfs create -o canmount=off -o mountpoint=none bpool/arch
zfs create -o canmount=off -o mountpoint=none bpool/arch/BOOT
zfs create -o canmount=off -o mountpoint=none rpool/arch/ROOT
zfs create -o canmount=off -o mountpoint=none rpool/arch/DATA
zfs create -o mountpoint=/boot -o canmount=noauto bpool/arch/BOOT/default
zfs create -o mountpoint=/ -o canmount=off    rpool/arch/DATA/default
zfs create -o mountpoint=/ -o canmount=noauto rpool/arch/ROOT/default
zfs mount rpool/arch/ROOT/default
zfs mount bpool/arch/BOOT/default

for i in {usr,var,var/lib};
do
    zfs create -o canmount=off rpool/arch/DATA/default/$i
done

for i in {home,root,srv,usr/local,var/log,var/spool};
do
    zfs create -o canmount=on rpool/arch/DATA/default/$i
done

mkfs.vfat -n EFI ${DISK1}-part1
mkdir -p /mnt/boot/efis/${DISK1##*/}-part1
mount -t vfat ${DISK1}-part1 /mnt/boot/efis/${DISK1##*/}-part1

mkfs.vfat -n EFI ${DISK2}-part1
mkdir -p /mnt/boot/efis/${DISK2##*/}-part1
mount -t vfat ${DISK2}-part1 /mnt/boot/efis/${DISK2##*/}-part1

mkdir -p /mnt/boot/efi
mount -t vfat ${DISK1}-part1 /mnt/boot/efi

pacstrap /mnt base nano mandoc grub efibootmgr mkinitcpio

nano /etc/pacman.conf
[archzfs]
Server = http://archzfs.com/$repo/x86_64

curl pacman-key -a archzfs.gpg -o archzfs.gpg
pacman-key -a archzfs.gpg
pacman-key --lsign-key DDF7DB817396A49B2A2723F7403BD972F75D9D76

pacstrap /mnt linux-firmware amd-ucode # intel-ucode on intel

nano /mnt/etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT=""
GRUB_CMDLINE_LINUX="zfs_import_dir=/dev/disk/by-id root=ZFS=rpool/arch/ROOT/default"

genfstab -U /mnt | sed 's;zfs[[:space:]]*;zfs zfsutil,;g' | grep "zfs zfsutil" >> /mnt/etc/fstab

echo UUID=$(blkid -s UUID -o value ${DISK1}-part1) /boot/efis/${DISK1##*/}-part1 vfat \
x-systemd.idle-timeout=1min,x-systemd.automount,noauto,umask=0022,fmask=0022,dmask=0022 0 1 >> /mnt/etc/fstab

echo UUID=$(blkid -s UUID -o value ${DISK2}-part1) /boot/efis/${DISK2##*/}-part1 vfat \
x-systemd.idle-timeout=1min,x-systemd.automount,noauto,umask=0022,fmask=0022,dmask=0022 0 1 >> /mnt/etc/fstab

echo UUID=$(blkid -s UUID -o value ${DISK1}-part1) /boot/efi vfat \
x-systemd.idle-timeout=1min,x-systemd.automount,noauto,umask=0022,fmask=0022,dmask=0022 0 1 >> /mnt/etc/fstab

mv /mnt/etc/mkinitcpio.conf /mnt/etc/mkinitcpio.conf.original
tee /mnt/etc/mkinitcpio.conf <<EOF
HOOKS=(base udev autodetect modconf block keyboard zfs filesystems)
EOF

nano /mnt/etc/systemd/network/20-main.network

[Match]
Name=enp10s0

[Network]
DNS=1.1.1.1
DHCP=no

[Address]
Address=192.168.10.225/24

[Route]
Gateway=192.168.10.1
Destination=192.168.10.0/24

systemctl enable systemd-networkd systemd-resolved --root=/mnt
hwclock --systohc
systemctl enable systemd-timesyncd --root=/mnt
rm -f /mnt/etc/localtime
systemd-firstboot --root=/mnt --force --prompt --root-password=PASSWORD
arch-chroot /mnt passwd
zgenhostid -f -o /mnt/etc/hostid

systemctl enable zfs-import-scan.service zfs-import.target zfs-zed zfs.target --root=/mnt
systemctl disable zfs-mount --root=/mnt

arch-chroot /mnt bash --login
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

nano /etc/pacman.conf
[archzfs]
Server = http://archzfs.com/$repo/x86_64

curl https://archzfs.com/archzfs.gpg -o archzfs.gpg
pacman-key -a archzfs.gpg
pacman-key --lsign-key DDF7DB817396A49B2A2723F7403BD972F75D9D76

pacman -S openssh
systemctl enable sshd

# recovery
curl -L https://git.io/Jsfr3 > /etc/grub.d/43_archiso
chmod +x /etc/grub.d/43_archiso

#grub
echo 'export ZPOOL_VDEV_NAME_PATH=YES' >> /etc/profile.d/zpool_vdev_name_path.sh
source /etc/profile.d/zpool_vdev_name_path.sh

# make sure to do DISK1 and DISK2 again

grub-install --boot-directory /boot/efi/EFI/arch --target=i386-pc $DISK1
grub-install --boot-directory /boot/efi/EFI/arch --target=i386-pc $DISK2

grub-mkconfig -o /boot/grub/grub.cfg
ESP_MIRROR=$(mktemp -d)
cp -r /boot/efi/EFI $ESP_MIRROR
for i in /boot/efis/*; do
 cp -r $ESP_MIRROR/EFI $i
done

exit

zfs snapshot -r rpool/arch@install
zfs snapshot -r bpool/arch@install

umount /mnt/boot/efi
umount /mnt/boot/efis/*

zpool export bpool
zpool export rpool


zpool import -d ${DISK1}-part2 -d ${DISK2}-part2 bpool -R /mnt
zpool import -d ${DISK1}-part3 -d ${DISK2}-part3 rpool -R /mnt

```
