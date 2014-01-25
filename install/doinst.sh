#!/bin/bash
source /usr/local/boiler/trolley/env
source /etc/bundlerc

PATH=$TROLLEY_LIB_PATH/setup:$PATH

if ! grep -Fxq "source /etc/bundlerc" /etc/profile; then
  echo 'source /etc/bundlerc' >> /etc/profile
fi

if [[ `uname -m` == "x86_64" ]]; then
  fetchpkg -p /slackware/d/python-2.7.5-x86_64-1.txz -s 14.1 -i

  plz.py install kernel-headers 3.10.17
  plz.py install binutils 2.23.52.0.1
  plz.py install glibc 2.17
  plz.py install gcc 4.8.2
  plz.py install gcc-g 4.8.2  # gcc-g++
  plz.py install libmpc 0.8.2
  plz.py install libelf 0.8.13
  plz.py install openssl 1.0.1f
  plz.py install automake 1.11.5
  plz.py install make 3.82
  plz.py install libyaml 0.1.4
  plz.py install mpfr 3.1.2
  plz.py install zlib 1.2.8
  plz.py install git 1.8.4
  plz.py install ruby 1.9.3_p484
else
  # Bootstrap package dependencies
  fetchpkg -p /slackware/d/python-2.6.6-i486-1.txz -s 13.37 -i

  plz.py install kernel-headers 2.6.37.6_smp
  plz.py install binutils 2.21.51.0.6
  plz.py install glibc 2.15
  plz.py install gcc 4.5.2
  plz.py install gcc-g 4.5.2  # gcc-g++
  plz.py install libmpc 0.8.2
  plz.py install libelf 0.8.13
  plz.py install openssl 1.0.1c
  plz.py install automake 1.11.5
  plz.py install make 3.82
  plz.py install curl 7.20.1
  plz.py install libyaml 0.1.4
  plz.py install mpfr 3.0.1
  plz.py install zlib 1.2.8
  plz.py install git 1.8.4
  plz.py install ruby 1.9.3_p484
fi


if [[ `gem -v` < "2.2" ]]; then
  gem update --system
fi

if [[ `command -v bundle` == "" ]]; then
  gem install bundler
fi
