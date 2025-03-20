#!/bin/bash

set -e

if [[ -z "${2}" ]]; then
    printf "Did not provide two arguments\n" 1>&2
    exit 1
fi

umount "${1}"
cryptsetup luksClose "${2}"
