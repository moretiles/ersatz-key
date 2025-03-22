#!/bin/bash

set -e

source ./scripts/config-file.sh

# Setup 2fa the way I like it

if [[ "$(id -u)" != "0" ]]; then
    printf "You are not root, this script requires root\n" 1>&2
    printf "It might be a good idea to look over the script before you install it\n" 1>&2
    exit 1
fi

if [[ -z "${1}" ]]; then
    printf "./install {LOCAL_CONFIG_PATH}" 1>&2
    printf "It might be a good idea to look over the script before you install it\n" 1>&2
    exit 2
fi

config_file="${1}"
mapper_name="$(field 'mapper_name' "${config_file}")"

chmod +x scripts/*
mkdir -p /usr/local/bin/ersatz-key/keepass/
cp scripts/shamir-keepass-decrypt.sh /usr/local/bin/ersatz-key/keepass
cp scripts/config-file.sh /usr/local/bin/ersatz-key/config-file.sh
cp units/keepassxc-shamir@.service /etc/systemd/system/

systemctl enable ersatz-key-shamir@"$(systemd-escape "${mapper_name}")".service
#systemctl enable keepassxc-shamir@a.service

systemctl daemon-reload
