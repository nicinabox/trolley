#!/bin/bash
source /usr/local/boiler/trolley/env
PATH=$TROLLEY_LIB_PATH/setup:$PATH

# Install package dependencies
fetchpkg -p /patches/packages/linux-2.6.37.6-3/kernel-headers-2.6.37.6_smp-x86-3.txz -s 13.37 -i
fetchpkg -p /patches/packages/glibc-2.15-i486-8_slack14.0.txz -s 14.0 -i
fetchpkg -p /slackware/n/curl-7.20.1-i486-1.txz -s 13.1 -i
fetchpkg -p /slackware/l/libyaml-0.1.4-i486-1.txz -s 14.1 -i
fetchpkg -p /slackware/n/openssl-1.0.1c-i486-3.txz -s 14.0 -i
fetchpkg -p /slackware/d/automake-1.11.5-noarch-1.txz -s 14.1 -i
fetchpkg -p /slackware/l/libmpc-0.8.2-i486-2.txz -s 14.1 -i
fetchpkg -p /slackware/l/libelf-0.8.13-i486-2.txz -s 14.1 -i
fetchpkg -p /slackware/l/mpfr-3.0.1-i486-1.txz -s 13.37 -i
fetchpkg -p /slackware/d/gcc-4.5.2-i486-2.txz -s 13.37 -i
fetchpkg -p /slackware/d/gcc-g++-4.5.2-i486-2.txz -s 13.37 -i
fetchpkg -p /slackware/d/binutils-2.21.51.0.6-i486-1.txz -s 13.37 -i
fetchpkg -p /slackware/d/automake-1.11.5-noarch-1.txz -s 14.1 -i
fetchpkg -p /slackware/d/make-3.82-i486-4.txz -s 14.1 -i
fetchpkg -p /slackware/l/zlib-1.2.8-i486-1.txz -s 14.1 -i

fetchpkg -p /slackware/d/git-1.8.4-i486-1.txz -s 14.1 -i
fetchpkg -p /patches/packages/ruby-1.9.3_p484-i486-1_slack14.1.txz -s 14.1 -i

