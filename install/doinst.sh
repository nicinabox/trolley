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
setuptools=https://pypi.python.org/packages/source/s/setuptools/setuptools-1.1.6.tar.gz
name=`basename $setuptools`
wget --no-check-certificate $setuptools
tar xzf $name && cd ${name%.*.*}
python setup.py install

# Install argparse
easy_install argparse
