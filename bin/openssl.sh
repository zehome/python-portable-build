#!/bin/bash

set -e

OPENSSL_ROOT=openssl-1.0.2o
OPENSSL_HASH=ec3f5c9714ba0fd45cb4e087301eb1336c317e0d20b575a125050470e8089e4d
OPENSSL_DOWNLOAD_URL="https://www.openssl.org/source"

. $(dirname $0)/common.sh

fetch_source $OPENSSL_ROOT.tar.gz $OPENSSL_DOWNLOAD_URL
check_sha256sum $OPENSSL_ROOT.tar.gz $OPENSSL_HASH
tar -xzf $OPENSSL_ROOT.tar.gz
(
    cd $OPENSSL_ROOT
    ./config shared
    make -j $CPUS
    make install
)
