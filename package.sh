#!/bin/bash

PACKAGE_DIR="./package/unbound/"
rm -fr "$PACKAGE_DIR"
mkdir -p "$PACKAGE_DIR"

sudo apt install -y libexpat-dev libhiredis-dev libssl-dev byacc
make clean
./configure --with-libhiredis
make -j4
objcopy --only-keep-debug unbound unbound.dbg
strip --strip-debug unbound
strip --strip-debug .libs/libunbound.so.8
strip --strip-debug unbound-control
LIBHIREDIS_FILE=$(ldd unbound | grep hiredis | cut -d ' ' -f 3)

if [ ! -f "$LIBHIREDIS_FILE" ]; then
  echo "Cannot find libhiredis so file"
  exit 1
fi

cp unbound .libs/libunbound.so.8 unbound-control .libs/unbound-anchor "$LIBHIREDIS_FILE" "$PACKAGE_DIR" 

wget https://www.internic.net/domain/named.root -qO- | tee "$PACKAGE_DIR"/root.hints

cd package/
tar -czf unbound.tar.gz unbound

