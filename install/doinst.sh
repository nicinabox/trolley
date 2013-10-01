#!/bin/bash

if [[ ! `command -v curl` ]]; then
  wget -qO- http://boxcar.nicinabox.com/install_curl | sh -
fi
