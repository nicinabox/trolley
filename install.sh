#!/bin/bash

version=0.1.5

wget -q --no-check-certificate \
     -O /boot/extra/trolley-$version-noarch-unraid.tgz \
     https://github.com/nicinabox/trolley/releases/download/$version/trolley-$version-noarch-unraid.tgz

installpkg /boot/extra/trolley-$version-noarch-unraid.tgz
