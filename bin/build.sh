#!/bin/bash

set -e

[ -z "$VERSION" ] && VERSION=3.6.6
VERSION_MAJOR=$(echo $VERSION | cut -f1,2 -d.)
VERSION_MINOR=$(echo $VERSION | cut -f3 -d.)
[ -z "$VERSION_MD5SUM" ] && PYTHON_MD5SUM=""
VERSION=${VERSION_MAJOR}.${VERSION_MINOR}

ROOT=$(pwd)
CPUS=$(cat /proc/cpuinfo | grep MHz | wc -l)

#apt-get -qq update
#apt-get -qqy install libncurses5-dev zlib1g-dev libssl-dev libbz2-dev libgdbm-dev libsqlite3-dev liblzma-dev libreadline-dev autoconf automake git-core

# Build patchelf from git master
# fixes bug increasing size of binary by 20 MiB
# https://github.com/NixOS/patchelf/commit/c4deb5e9e1ce9c98a48e0d5bb37d87739b8cfee4
(
    git clone https://github.com/NixOS/patchelf.git
    cd patchelf
    ./bootstrap.sh
    ./configure
    make -j $CPUS
)

wget https://www.python.org/ftp/python/${VERSION}/Python-${VERSION}.tar.xz
if [ -z "$PYTHON_MD5SUM" ]; then
    echo "Bypass hash check"
else
    echo "$PYTHON_MD5SUM *Python-${VERSION}.tar.xz" > Python-${VERSION}.md5sum
    md5sum --quiet -c Python-${VERSION}.md5sum
fi
tar xf Python-${VERSION}.tar.xz
(
    cd Python-${VERSION}
    ./configure --enable-shared --enable-optimizations --with-lto --prefix $ROOT/python-${VERSION}/
    make -j $CPUS
    make altinstall
)

echo "Create python and python3 link"
(
    cd $ROOT/python-${VERSION}/bin
    ln -s python${VERSION_MAJOR} python
    ln -s python${VERSION_MAJOR} python3
)

echo "Patchelf (set rpath to $ORIGIN/../lib)"
patchelf/src/patchelf --set-rpath '$ORIGIN/../lib' python-${VERSION}/bin/python${VERSION_MAJOR}
patchelf/src/patchelf --set-rpath '$ORIGIN/../lib' python-${VERSION}/bin/python${VERSION_MAJOR}m

echo "Copy system libraries"
syslibs=$(find $ROOT/python-${VERSION} -name '*.so' | \
    xargs ldd | grep x86_64-linux | \
    grep -Ev 'libc|libm|libdl|libutil|libpthread|libnsl|libssl' | \
    grep '=>'|awk '{print $3'}|sort -u)
for lib in ${syslibs}; do
    cp -v ${lib} $ROOT/python-${VERSION}/lib
done

echo "Remove tests idle and tkinter"
for d in tkinter sqlite3/test idlelib test; do
    rm -rf $ROOT/python-${VERSION}/lib/python${VERSION_MAJOR}/${d}
done

echo "Remove __pycache__"
find $ROOT/python-${VERSION} -name __pycache__ -type d | xargs rm -rf

echo "Update PIP and install virtualenv"
python-${VERSION}/bin/python -m pip install -U pip

echo "Patch sheebang"
for f in $(grep -rl '^#!'"$ROOT"'/python-'"${VERSION}"'/bin/python' $ROOT/python-${VERSION}/bin/*); do
    sed -i 's,^#!'"$ROOT"'/python-'"$VERSION"'/bin/python.*,#!/usr/bin/perl -e$_=$ARGV[0];exec(s/\\w+$/python/r\,$_\,@ARGV[1..$#ARGV]),' $f
    echo "[+] patched $f"
done

echo "Build archive"
glibc_version=$(dpkg -s libc6|grep Version|awk '{print $2}'|cut -f1 -d-)
tar cJf python-${VERSION}-linux-$(uname -m)-glibc-${glibc_version}.tar.xz python-${VERSION}/
