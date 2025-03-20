#!/bin/bash

# make sure this is run by the dv user
# important that /tmp is located in memory so that the unsealed password is not writen to disk when it is unneeded

set -e

if [[ -z "${1}" ]]; then
    printf "There is no shamir keep mentioned...\n" 1>&2
    printf "Either you did something wrong or the systemd installation failed\n" 1>&2
    exit 1
fi

LOCAL_SHAMIR_KEY="${1}"

mkdir -p /tmp/usb-shamir-unseal
chmod 700 /tmp/usb-shamir-unseal/
touch /tmp/usb-shamir-unseal/keepassxc-pw
chmod 600 /tmp/usb-shamir-unseal/keepassxc-pw
/usr/bin/cat "${LOCAL_SHAMIR_KEY}" /usb/keepassxc/shamir-3 | /home/dv/.local/bin/shamir combine -k 2 > /tmp/usb-shamir-unseal/keepassxc-pw
