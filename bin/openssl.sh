#!/bin/bash

set -e

ROOT=$(dirname $0)
ROOT=$(realpath $ROOT)

. $ROOT/common.sh

#OPENSSL_VERSION=$($ROOT/checkupdate.sh -owner openssl -repository openssl -match ">=1.1.0,<1.2" -quiet)
OPENSSL_VERSION=1.1.0f
OPENSSL_ROOT=openssl-${OPENSSL_VERSION}
OPENSSL_DOWNLOAD_URL="https://www.openssl.org/source/" # openssl-1.1.1c.tar.gz

fetch_source $OPENSSL_ROOT.tar.gz $OPENSSL_DOWNLOAD_URL
tar -xzf $OPENSSL_ROOT.tar.gz
(
    cd $OPENSSL_ROOT
    #./configure --enable-shared  CFLAGS=-fPIC --prefix=$(realpath $ROOT)/openssl
    ./config --prefix=$(realpath $ROOT/../openssl)
    make -j $CPUS
    make install
)
