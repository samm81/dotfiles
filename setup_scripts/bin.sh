#!/usr/bin/env bash
. util/header.sh

function download_tar() {
	wget "${1}"
	tar xvf ${1##*/}
	rm ${1##*/}
}

function download_zip() {
	wget "${1}"
	unzip ${1##*/}
	rm ${1##*/}
}


check_installed wget
check_installed tar
check_installed unzip

cd ~/bin/

# TODO k

# dust
download_tar "https://github.com/bootandy/dust/releases/download/v0.4.2/dust-v0.4.2-x86_64-unknown-linux-gnu.tar.gz"

# exa
download_zip "https://github.com/ogham/exa/releases/download/v0.9.0/exa-linux-x86_64-0.9.0.zip"
mv exa-linux-x86_64 exa
