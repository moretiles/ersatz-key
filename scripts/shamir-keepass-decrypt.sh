#!/bin/bash

set -e

# config-file includes the field method which gets the value part of a key-value pair
# if the file includes lines like 'a=b'
source /usr/local/bin/ersatz-key/config-file.sh

# make sure this is run by the dv user
# important that /tmp is located in memory so that the unsealed password is not writen to disk when it is unneeded

if [[ -z "${1}" ]]; then
    printf "There is no config mentioned...\n" 1>&2
    printf "Either you did something wrong or the systemd installation failed\n" 1>&2
    exit 1
fi

config_file="${1}"

user="$(field 'user' "${config_file}")"
group="$(field 'group' "${config_file}")"
local_shamir_key="$(field 'local_shamir_key' "${config_file}")"
external_shamir_key="$(field 'external_shamir_key' "${config_file}")"
output_location="$(field 'output_location' "${config_file}")"
output_dir="${output_location%/*}"

mkdir -p "${output_dir}"
touch "${output_location}"
chmod 600 "${output_location}"
cat "${local_shamir_key}" "${external_shamir_key}" | /home/dv/.local/bin/shamir combine -k 2 > "${output_location}"
chown -R "${user}":"${group}" "${output_location}"
