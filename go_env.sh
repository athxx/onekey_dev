#!/bin/bash

################### GO ENV ###################
get_latest_version() {
  VER=$(curl -s --connect-timeout 10 https://go.dev/VERSION?m=text)
  VER=${VER:2}
  if [ ${#VER} -eq 0 ]; then
    VER=1.19.1
    echo -e "\033[1;32musing default version ${VER}\033[0m"
  fi
}

version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; }

install_go() {
  if [ ! -x "$(command -v go)" ]; then
    cd $INS_DIR
    curl -o $GO_VER $DL_MIRROR
    tar -zxf $GO_VER
    rm -rf $GO_VER
    chmod -R 755 $INS_DIR/go
    ln -s $INS_DIR/go/bin/go /usr/bin/go
    ln -s $INS_DIR/go/bin/gofmt /usr/bin/gofmt
    go env -w GOROOT=$INS_DIR/go
    go env -w GOBIN=$INS_DIR/go/bin
    go env -w GOPATH=$INS_DIR/go
    echo -e "\033[1;32mgo $VER successfully installed.\033[0m"
    exit 0
  fi
}

update_go() {
  if [ "$VER" = "$OLD_VER" ]; then
    echo -e "\033[1;31myou are using latest version, exited.\033[0m"
    exit 0
  fi

  if version_gt $VER $OLD_VER; then
    echo -e "upgrading go version ${VER}\033[1;32m"
    cd $INS_DIR
    rm -rf $INS_DIR/go
    curl -o $GO_VER $DL_MIRROR
    tar -zxf $GO_VER
    rm -rf $GO_VER
    chmod -R 755 $INS_DIR/go
    echo -e "\033[1;32mupgraded go version to go ${VER}.\033[0m"
    exit 0
  fi
}

remove_go() {
  GO_LINK=$(which go)
  rm -rf $GO_LINK
  rm -rf $INS_DIR
  echo -e "\033[1;32mremove all go files, if you set environment variables, please remove them manually.\033[0m"
  exit 0
}

# shellcheck disable=SC2120
check_args() {
    echo ''
    echo -e "Usage:"
    echo -e '\t./go_env.sh <command> [version]'
    echo ''
    echo -e '\t\033[1;32mgo_env.sh install 1.19.1\033[0m'
    echo ''
    echo 'The commands are:'
    echo ''
    echo -e "\tinstall\t\tdownload and install golang, [version] is optional, default is latest version"
    echo -e "\tupdate\t\tdefault update to latest version. [version] is optional, default is latest version"
    echo -e "\tremove\t\tto remove golang, some environment variables need to remove by manually."
    echo ''
    exit 0;
}

##################### 1. check arguments #####################
if [ "$1" == "" ]; then
  check_args
fi

##################### 2. get latest version #####################
if [ "$2" == "" ]; then
  get_latest_version
else
  VER=$2
fi

##################### 3. set variables #####################
GO_VER=go$VER.linux-amd64.tar.gz
if [[ $(uname) == 'Darwin' ]]; then
  GO_VER=go$VER.darwin-amd64.tar.gz
fi
INS_DIR=/usr/local
DL_MIRROR=https://gomirrors.org/dl/go/$GO_VER

##################### 4. install #####################
if [ "$1" == "install" ]; then
    install_go
fi

##################### 4. if exist, get variables #####################
INS_DIR=$(go env GOROOT)
OLD_VER=$(go version | awk '{print $3}')
OLD_VER=${OLD_VER:2}

##################### 5. golang exist, try to update #####################
if [ "$1" == "update" ]; then
  update_go
fi

##################### 6. remove go #####################
if [ "$1" == "remove" ]; then
  remove_go
fi

##################### 7. recheck #####################
check_args
