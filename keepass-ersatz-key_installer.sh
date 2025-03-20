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

if [[ -z "${1}" ]]; then
    printf "./install {LOCAL_SHAMIR_SEAL_PATH}" 1>&2
    printf "It might be a good idea to look over the script before you install it\n" 1>&2
    exit 2
fi

local_shamir_seal_path="${1}"

chmod +x scripts/*
mkdir -p /usr/local/bin/ersatz-key/keepass/
cp scripts/shamir-keepass-decrypt.sh /usr/local/bin/ersatz-key/keepass
cp units/keepassxc-shamir@.service /etc/systemd/system/

systemctl enable keepassxc-shamir@"$(systemd-escape "${local_shamir_seal_path}")".service
#systemctl enable keepassxc-shamir@a.service

systemctl daemon-reload
