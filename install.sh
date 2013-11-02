#!/bin/bash

version=0.1.5

# Remove old file versions
rm -rf /boot/extra/trolley*

# Download new
wget -q --no-check-certificate \
     -O /boot/extra/trolley-$version-noarch-unraid.tgz \
     https://github.com/nicinabox/trolley/releases/download/$version/trolley-$version-noarch-unraid.tgz

# Install
installpkg /boot/extra/trolley-$version-noarch-unraid.tgz
