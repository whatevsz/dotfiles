#!/usr/bin/env bash
#
# Wraps "make" and ensures basic packages are installed:
#
# - make itself
# - python3-virtualenv (needed for ansible)

set -o errexit
set -o nounset

os_release_file=/etc/os-release
if [[ ! -e "${os_release_file}" ]] ; then
    2>&1 printf "Could not find ${os_release_file}, exiting"
    exit 1
fi

source /etc/os-release

_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

sudowrap() {
    if (( $(id -u ) != 0 )) ; then
        sudo "${@}"
    else
        "${@}"
    fi
}

_install() {
    _package="$1" ; shift
    if [[ $NAME == "Fedora" ]] ; then
        sudowrap dnf install --assumeyes "${_package}"
    elif [[ $NAME == "Ubuntu" ]] ; then
        sudowrap apt-get install --assume-yes "${_package}"
    elif [[ $NAME == "Arch Linux" ]] ; then
        sudowrap pacman -S --noconfirm "${_package}"
    else
        2>&1 printf "Unsupported distro $NAME, exiting"
        exit 1
    fi
}

if ! command -v make >/dev/null ; then
    printf 'Make not installed, installing ...\n'
    _install "make"
    printf 'Done\n'
fi

# Required for compiling modules in venv.
if ! command -v gcc >/dev/null ; then
    printf 'gcc not installed, installing ...\n'
    _install "gcc"
    printf 'Done\n'
fi

if ! python3 -c 'import venv' 2>/dev/null ; then
    printf 'Python3 venv module not installed, installing ...\n'
    _install python3-venv
    printf 'Done\n'
fi

cd "$_SCRIPT_DIR" && make
