#!/bin/bash

# Install curl, if needed
if [[ ! `command -v curl` ]]; then
  wget -qO- http://boxcar.nicinabox.com/install_curl | sh -
fi

# Install python 2.6.6, if needed
if [[ ! `command -v python` ]]; then
  python_url=http://slackware.cs.utah.edu/pub/slackware/slackware-13.37/slackware/d/python-2.6.6-i486-1.txz
  name=`basename $python_url`
  wget $python_url
  installpkg $name
  mv $name /boot/extra
fi

# Install setuptools
if [[ ! `command -v easy_install` ]]; then
  curl -skL https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py | python
fi

# Install argparse
easy_install argparse

# Symlink plz
cd /usr/local/bin; ln -s trolley plz

# Create dir /boot/extra
mkdir -p /boot/extra
