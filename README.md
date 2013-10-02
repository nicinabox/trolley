# Trolley

A simple package tool for Slackware, designed for unRAID.

## Install

    wget -q --no-check-certificate \
         -O trolley-0.1.1-i486-1.txz \
         https://github.com/nicinabox/trolley/releases/download/0.1.1/trolley-0.1.1.txz
    installpkg trolley-0.1.1-i486-1.txz

You may need to reopen your terminal session after installing.

## Usage

    usage: trolley [-h] [-v] {install,remove,list,search,update} ...

    positional arguments:
      {install,remove,list,search,update}
        install             Install a package by name
        remove              Remove installed package by name
        list                List installed packages
        search              Find a package by name
        update              Update trolley

    optional arguments:
      -h, --help            show this help message and exit
      -v, --version         Show version

If you want a package to be installed on reboot, move it to `/boot/extra`.

## Examples

Versions are listed in descending slackware versions (14.0, 13.37, 13.1).

Search an exact name

    ~# trolley search git
    git (1.7.12.1, 1.7.4.4, 1.7.1)

Search with a name fragment

    ~# trolley search open
    -video-openchrome (0.2.906, 0.2.904)
    openvpn (2.2.2, 2.1.4, 2.1.1)
    openssl-solibs (1.0.1c, 0.9.8r, 0.9.8n)
    openssl (1.0.1c, 0.9.8r, 0.9.8n)
    openexr (1.7.0, 1.6.1)
    openssh (6.1p1, 5.8p1, 5.5p1)
    openobex (1.5)
    openldap-client (2.4.31, 2.4.23, 2.4.21)

Install a package

    ~# trolley install git
    Downloading package data
    Verifying package git-1.7.12.1-i486-1.txz.
    Installing package git-1.7.12.1-i486-1.txz:
    PACKAGE DESCRIPTION:
    # git (the stupid content tracker)
    #
    # Git is a fast, scalable, distributed revision control system with an
    # unusually rich command set that provides both high-level operations
    # and full access to internals.
    #
    # "git" can mean anything, depending on your mood.
    #
    # Git was originally written by Linus Torvalds and is currently
    # maintained by Junio C. Hamano.
    #
    Executing install script for git-1.7.12.1-i486-1.txz.
    Package git-1.7.12.1-i486-1.txz installed.

