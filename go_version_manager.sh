#!/bin/bash

# manage-go installs/manages the go toolchain
# author github.com/insomnimus
# released under the MIT license

shopt -s nocasematch

_root="$HOME/goroot"
_force=0
_yes=0
_cmd="$0"
_action=""

function _confirm() {
	if [[ $_yes -ne 0 ]]; then
		return
	fi

	read -p "$1 " -n 1 -r
	if [[ ! $REPLY =~ ^[Yy]|yes$ ]]; then
		echo "cancelled"
		exit 0
	fi
}

if [[ ! -z $GOROOT ]]; then
	_root="$GOROOT"
fi

function _show_help() {
	cat <<END
install/manage the go toolchain
usage:
	$_cmd <COMMAND> [OPTIONS] [TAG]
commands:
	install: clones the go source into ~/goroot (or \$GOROOT), then builds it
	update, upgrade: updates the go installation by pulling the source in ~/goroot (or \$GOROOT) and building it

options are:
	-force: update even if the source is up to date
	-y: do not prompt for confirmation
	-h, --help: show this message and exit

tag:
	go version or branch to install, default is master for installation and the checked out version for update
	for example \`go1.16.4\`

you can set the \$GOROOT env variable to the directory to clone and install the go source to (if it's unset, ~/goroot is assumed)
to use this script, you need a go compiler for bootstrapping
set the \$GOROOT_BOOTSTRAP env variable to the root of the go bootstrap directory (usually the existing but outdated go installation root) if the go tool is not under your \$PATH
END
}

function _install() {
	if [ -d "$_root" ]; then
		echo 1>&2 "the $_root directory already exists; can't determine if it's the go source. please rename or remove $_root before running this script"
		exit 2
	fi

	set -e
	_confirm "clone and install go?"

	cd ~
	git clone https://go.googlesource.com/go "$_root"
	cd "$_root"
	[ ! -z "$_tag" ] && git checkout "$_tag"

	echo "successfully cloned the go source into $_root"
	echo "building"
	cd src
	./make.bash
	echo "done"
	echo "you may want to add ${_root}/bin to your \$PATH"
}

function _update() {
	if [ ! -d "${_root}/.git" ]; then
		echo 1>&2 "couldn't detect an installed go source tree in ${_root}; please install with $($_cmd install) first"
		exit 2
	fi

	set -e
	cd "$_root"
	if [[ ! -z $_tag ]]; then
		git checkout "$_tag"
	else
		_out=$(git pull)
	fi

	if [[ $_out = "Already up to date." ]]; then
		if [[ $_force -eq 0 ]]; then
			echo "already up to date, run with -force to build anyway"
			exit 0
		else
			echo "already up to date"
		fi
	else
		echo "pulled the latest changes"
	fi

	_confirm "proceed with installation? "

	echo "building"
	cd src
	./make.bash
	echo "done"
}

if [[ $# -eq 0 ]]; then
	_show_help
	exit 0
fi

for _arg in "$@"; do
	case "$_arg" in
	install) _action="install" ;;
	update | upgrade) _action="update" ;;
	-y) _yes=1 ;;
	-force) _force=1 ;;
	-h | --help | help) _show_help && exit 0 ;;
	*) _tag="$_arg" ;;
	esac
done

if [[ -z $_action ]]; then
	echo 1>&2 "missing subcommand. run with --help for the usage"
	exit 2
fi

if [[ $_action = "install" ]]; then
	_install
else
	_update
fi

