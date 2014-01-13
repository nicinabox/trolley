#!/bin/bash

# Create dir /boot/extra
mkdir -p /boot/extra

# Install curl, if needed
if [[ ! `command -v curl` ]]; then

  # Will it be installed?
  if [ ! -e /boot/extra/curl* ]; then
    wget -qO- http://boxcar.nicinabox.com/install_curl | sh -
  fi
fi

# Install python 2.6.6, if needed
if [[ ! `command -v python` ]]; then
  if [ ! -e /boot/extra/python* ]; then
    python_url=http://slackware.cs.utah.edu/pub/slackware/slackware-13.37/slackware/d/python-2.6.6-i486-1.txz
    name=`basename $python_url`
    wget $python_url
    installpkg $name
    mv $name /boot/extra
  fi
fi

# Install setuptools
if [[ ! `command -v easy_install` ]]; then
  wget --no-check-certificate -O- https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py | python - --insecure
fi

# Install argparse
easy_install argparse

# Symlink plz
cd /usr/local/bin; ln -fs trolley plz
