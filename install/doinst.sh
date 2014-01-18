#!/bin/bash
source /usr/local/boiler/trolley/env
PATH=$TROLLEY_LIB_PATH/setup:$PATH

# Install package dependencies
fetchpkg -p /slackware/n/curl-7.20.1-i486-1.txz -s 13.1 -i
fetchpkg -p /slackware/d/python-2.6.6-i486-1.txz -s 13.37 -i

# Install setuptools
if [[ ! `command -v easy_install` ]]; then
  python $TROLLEY_LIB_PATH/setup/ez_setup.py install --insecure
fi

# Install argparse
easy_install argparse
