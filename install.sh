#!/bin/bash

version=0.1.4

wget -q --no-check-certificate \
     -O /boot/extra/trolley-$version-noarch-unraid.txz \
     https://github.com/nicinabox/trolley/releases/download/$version/trolley-$version-noarch-unraid.txz

installpkg /boot/extra/trolley-$version-noarch-unraid.txz
