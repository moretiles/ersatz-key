#!/bin/bash

after-eq () {
    if [[ -z "${2}" ]]; then
        echo "You did not properly supply two argument to after-eq" 1>&2
        exit 1
    fi
    grep "${1}" "${2}" | cut -d= -f2-
}

field () {
    if [[ -z "${2}" ]]; then
        echo "You did not properly supply two argument to after-eq" 1>&2
        exit 2
    fi
    after-eq "^${1}=" "${2}"
}

