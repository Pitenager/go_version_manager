#!/bin/bash

# installs go
function install_go() {
    echo "Installing Go from source\n"
    cd ~
    git clone https://go.googlesource.com/go goroot
    cd goroot
    src/make.bash
}

# updates go
function update_go() {
    echo "Updating existing Go installation to latest version\n"
    cd ~/goroot
    git pull
    src/make.bash
}

function usage()
{
    echo "Go version Manager"
    echo ""
    echo "Usage: ./go_version_manager.sh <install | update>"
    echo ""
}

PARAM="$(printf "%s\n" $1 | awk -F= '{print $1}')"
if [ "$PARAM" = "install" ]; then
    install_go
elif [ "$PARAM" = "update" ]; then
    update_go
else
    usage
fi
