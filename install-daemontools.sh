#!/bin/sh
VERSION=0.76

# Suppress an unwanted install step
mkdir /service

# Make the package directory
mkdir -p -m 1755 /package
cd /package

# Download daemontools
wget https://cr.yp.to/daemontools/daemontools-${VERSION}.tar.gz
tar -xpzf daemontools-${VERSION}.tar.gz
rm -f daemontools-${VERSION}.tar.gz

# Build daemontools
cd admin/daemontools-${VERSION}
sed -i 's}^\(gcc.*\)$}\1 -include /usr/include/errno.h}' src/conf-[cl][cd]
patch -p1 < /tmp/daemontools.patch
./package/install
