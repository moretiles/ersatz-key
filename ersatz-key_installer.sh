#!/bin/bash

set -e

# Setup 2fa the way I like it

cryptroot_name=usb-luks
cryptroot_path=/dev/mapper/"${cryptroot_name}"

if [[ "$(id -u)" != "0" ]]; then
    printf "You are not root, this script requires root\n" 1>&2
    printf "It might be a good idea to look over the script before you install it\n" 1>&2
    exit 1
fi

if [[ -z "${2}" ]]; then
    printf "./install {ENCRYPTED_PARTITION} {KEY_FILE_TO_DECRYPT_PARTITION}\n" 1>&2
    printf "It might be a good idea to look over the script before you install it\n" 1>&2
    exit 2
fi

encrypted_partition="${1}"
key_file="${2}"

cryptsetup luksOpen --key-file="${key_file}" "${encrypted_partition}" "${cryptroot_name}"

uuid_crypttab="$(blkid -o udev "${encrypted_partition}" | grep 'ID_FS_UUID=' | awk -F= '{print $2}')"
uuid_fstab="$(blkid -o udev "${cryptroot_path}" | grep 'ID_FS_UUID=' | awk -F= '{print $2}')"

printf "%s\tUUID=%s\t%s\t%s\n" usb-luks "${uuid_crypttab}" "${key_file}" luks >> /etc/crypttab

printf "\n" >> /etc/fstab
echo "# ${cryptroot_path}" >> /etc/fstab
printf "UUID=%s\t%s\t%s\t%s\t%s\t%s\n" "${uuid_fstab}" /usb ext4 rw,relatime 0 2 >> /etc/fstab

cryptsetup luksClose "${cryptroot_name}"

chmod +x scripts/*
mkdir -p /usr/local/bin/ersatz-key
cp scripts/unmount-and-seal.sh /usr/local/bin/ersatz-key
cp units/unmount-usb.service units/unseal-usb.target /etc/systemd/system

systemctl enable unmount-usb.service
systemctl enable unseal-usb.target

systemctl daemon-reload
