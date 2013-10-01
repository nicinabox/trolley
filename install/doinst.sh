#!/bin/bash

if [[ ! `command -v curl` ]]; then
  wget -qO- http://boxcar.nicinabox.com/install_curl | sh -
fi

if [[ ! `command -v python` ]]; then
  wget http://slackware.cs.utah.edu/pub/slackware/slackware-14.0/slackware/d/python-2.7.3-i486-2.txz
  installpkg python-2.7.3-i486-2.txz
  mv python-2.7.3-i486-2.txz /boot/extra
fi
