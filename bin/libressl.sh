#!/bin/bash

set -e

ROOT=$(dirname $0)
ROOT=$(realpath $ROOT)

. $ROOT/common.sh

LIBRESSL_VERSION=$($ROOT/checkupdate.sh -owner libressl-portable -repository portable -quiet)

LIBRESSL_ROOT=libressl-${LIBRESSL_VERSION}
LIBRESSL_DOWNLOAD_URL="https://ftp.openbsd.org/pub/OpenBSD/LibreSSL"


fetch_source $LIBRESSL_ROOT.tar.gz $LIBRESSL_DOWNLOAD_URL
tar -xzf $LIBRESSL_ROOT.tar.gz
(
    cd $LIBRESSL_ROOT
    ./configure --enable-shared  CFLAGS=-fPIC --prefix=$ROOT/openssl
    make -j $CPUS
    make install
)
