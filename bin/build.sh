#!/bin/bash

set -e

. $(dirname $0)/common.sh

[ -z "$PGO_ENABLED" ] && PGO_ENABLED=1

if [ ! -z "$1" ]; then
    # githubchecker fails to recognize 3.8.0b1
    # as a version, it's transformed to 3.8.0-b1
    VERSION=$(echo $1 | sed -e 's/-//')
else
    [ -z "$VERSION" ] && VERSION=3.7.2
fi
DIRVERSION=$(echo $VERSION | grep -o '[0-9]\.[0-9]\.[0-9]')
VERSION_MAJOR=$(echo $VERSION | cut -f1,2 -d.)
VERSION_MINOR=$(echo $VERSION | cut -f3 -d.)
[ -z "$VERSION_MD5SUM" ] && PYTHON_MD5SUM=""

ROOT=$(pwd)

# Build patchelf from git master
# fixes bug increasing size of binary by 20 MiB
# https://github.com/NixOS/patchelf/commit/c4deb5e9e1ce9c98a48e0d5bb37d87739b8cfee4
if [ ! -d patchelf ]; then
(
    git clone https://github.com/NixOS/patchelf.git
    cd patchelf
    ./bootstrap.sh
    ./configure
    make -j $CPUS
)
fi

echo "Build python ${VERSION}"
fetch_source Python-${VERSION}.tar.xz https://www.python.org/ftp/python/${DIRVERSION}
if [ -z "$PYTHON_MD5SUM" ]; then
    echo "Bypass hash check"
else
    echo "$PYTHON_MD5SUM *Python-${VERSION}.tar.xz" > Python-${VERSION}.md5sum
    md5sum --quiet -c Python-${VERSION}.md5sum
fi
export PKG_CONFIG_PATH=/usr/local/ssl/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/usr/local/ssl/lib:$ROOT/python-${VERSION}/lib:$LD_LIBRARY_PATH
tar xf Python-${VERSION}.tar.xz
(
    cd Python-${VERSION}
    if [ "$PGO_ENABLED" = "1" ]; then
        ./configure --enable-optimizations --with-lto --enable-shared --prefix $ROOT/python-${VERSION}/
    else
        ./configure --enable-shared --prefix $ROOT/python-${VERSION}/
    fi
    make -j $CPUS
    make altinstall
)

echo "Create python and python3 link"
pushd $ROOT/python-${VERSION}/bin
[ ! -f python ] && ln -s python${VERSION_MAJOR} python
[ ! -f python3 ] && ln -s python${VERSION_MAJOR} python3
popd

echo "Copy system libraries"
syslibs=$(find $ROOT/python-${VERSION}/lib/python${VERSION_MAJOR}/lib-dynload -name '*.so*' | \
    xargs ldd | grep '=>' | \
    grep -Ev 'libc\.|libm|libdl|libutil|libpthread|libpython|libnsl|linux-vdso' | \
    awk '{print $3'}|sort -u)
for lib in ${syslibs}; do
    cp -v ${lib} $ROOT/python-${VERSION}/lib
done
find "$ROOT/python-${VERSION}/lib/" -name '*.so*' -type f -perm -u=w | xargs strip

echo "Patchelf (set rpath to $ORIGIN/../lib)"
patchelf/src/patchelf --set-rpath '$ORIGIN/../lib' python-${VERSION}/bin/python${VERSION_MAJOR}
if [ -f python-${VERSION}/bin/python${VERSION_MAJOR}m ]; then
    patchelf/src/patchelf --set-rpath '$ORIGIN/../lib' python-${VERSION}/bin/python${VERSION_MAJOR}m
fi

echo "Patchelf (dynlib)"
for lib in python-${VERSION}/lib/python${VERSION_MAJOR}/lib-dynload/*.so; do
    patchelf/src/patchelf --set-rpath '$ORIGIN/../../' $lib
done

echo "Remove tests idle and tkinter"
for d in tkinter sqlite3/test idlelib test; do
    rm -rf $ROOT/python-${VERSION}/lib/python${VERSION_MAJOR}/${d}
done

echo "Update PIP and install virtualenv"
python-${VERSION}/bin/python -m pip install -U pip

echo "Patch sheebang"
for f in $(grep -rl '^#!'"$ROOT"'/python-'"${VERSION}"'/bin/python' $ROOT/python-${VERSION}/bin/*); do
    sed -i 's,^#!'"$ROOT"'/python-'"$VERSION"'/bin/python.*,#!/usr/bin/perl -e$_=$ARGV[0];exec(s/\\w+$/python/r\,$_\,@ARGV[1..$#ARGV]),' $f
    echo "[+] patched $f"
done

echo "Remove __pycache__"
find $ROOT/python-${VERSION} -name __pycache__ -type d | xargs rm -rf

echo "Remove lib/pkgconfig && lib/config-*"
rm -rf "$ROOT/python-${VERSION}/lib/pkgconfig" "$ROOT/python-${VERSION}/lib/python${VERSION_MAJOR}/config-${VERSION_MAJOR}*"

echo "Patch sysconfig module for relocation"
sysconfig_module_name=$($ROOT/python-${VERSION}/bin/python -c "import sys; print('_sysconfigdata_{0}_{1}_{2}.py'.format(sys.abiflags, sys.platform, getattr(sys.implementation, '_multiarch', '')))")
cat >>$ROOT/python-${VERSION}/lib/python${VERSION_MAJOR}/${sysconfig_module_name} <<EOF
# python-portable patch: change LIBDIRS & such at runtime
import sys
import os

_build_time_vars = build_time_vars
prefix = _build_time_vars["prefix"]
runtimeprefix = os.path.abspath(
    os.path.join(os.path.dirname(os.path.realpath(sys.executable)), ".."))
_build_time_vars = _build_time_vars
build_time_vars = {k: v.replace(prefix, runtimeprefix) if isinstance(v, str) else v for k, v in _build_time_vars.items()}
EOF

echo "Build archive"
glibc_version=$(dpkg -s libc6|grep Version|awk '{print $2}'|cut -f1 -d-)
libressl_version=$(/usr/local/ssl/bin/openssl version -v|awk '{print $2}')
if [ "$PGO_ENABLED" = "1" ]; then
    OPT="pgo-"
else
    OPT=""
fi
tar -cJf python-${VERSION}-linux_$(uname -m)-${OPT}libressl_${libressl_version}-glibc_${glibc_version}.tar.xz python-${VERSION}/
