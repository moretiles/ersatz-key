#!/bin/bash

#set -mex
set -e

source ./scripts/config-file.sh

if [[ "$(id -u)" != "0" ]]; then
	printf "You are not root, this script requires root\n" 1>&2
	printf "It might be a good idea to look over the script before you install it\n" 1>&2
	exit 1
fi

if [[ -z "${1}" ]]; then
	printf "./new_partition {LOCAL_CONFIG_PATH}" 1>&2
	printf "It might be a good idea to look over the script before you install it\n" 1>&2
	exit 2
fi

mkdir -p out

config_file="${1}"

keyfile="$(field keyfile "${config_file}")"
block_device="$(field block_device "${config_file}")"
mapper_name="$(field mapper_name "${config_file}")"
first="$(field first "${config_file}")"

head -c 256 /dev/urandom > "${keyfile}"
if [[ "${first}" == yes ]]; then
    begin='2048s'
else
    last=$(parted "${block_device}" 'unit s print' | tail -n2 | awk '$1 ~ /[0-9]+/ { print $3 }' | grep -o '[0-9]\+')
    begin="$((last + 2048))s"
fi
end="$((last + (100 * 2048)))s"
parted -s -a optimal -- "${block_device}" mkpart "${mapper_name}" ext4 "${begin}" "${end}"
sleep 1
new_part="$(fdisk -l "${block_device}" | tail -n 1 | awk '{print $1}')"
cryptsetup --batch-mode luksFormat "${new_part}" "${keyfile}"
sleep 1
cryptsetup luksOpen "${new_part}" "${mapper_name}" --key-file "${keyfile}"
sleep 1
sudo mkfs.ext4 /dev/mapper/"${mapper_name}"
sleep 1
cryptsetup luksClose "${mapper_name}"
sleep 1
