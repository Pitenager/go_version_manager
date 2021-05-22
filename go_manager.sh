#!/bin/bash

#Bootstrap toolchain
function bootstrap_toolchain() {
    sudo apt-get install gccgo-5
    sudo update-alternatives --set go /usr/bin/go-5
    export GOROOT_BOOTSTRAP=/usr ./make.bash
}

# installs go
function install_go() {
    echo "Installing Go from source\n"
    cd ~
    git clone https://go.googlesource.com/go goroot
    cd goroot/src
    ./all.bash
}

# updates go
function update_go() {
    echo "Updating existing Go installation to latest version\n"
    cd ~/goroot
    git pull
    cd src/
    ./all.bash
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
    bootstrap_toolchain
    install_go
elif [ "$PARAM" = "update" ]; then
    update_go
else
    usage
fi
