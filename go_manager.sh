# installs go
function install_go() {
    cd ~
    git clone https://go.googlesource.com/go goroot
    cd goroot
    src/make.bash
}

# updates go
function update_go() {
    cd ~/goroot
    git pull
    src/make.bash
}
