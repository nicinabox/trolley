# Trolley

A simple package tool for Slackware, designed for unRAID.

## Install

    wget -q --no-check-certificate \
         -O /boot/extra/trolley-0.1.3-noarch-unraid.txz \
         https://github.com/nicinabox/trolley/releases/download/0.1.3/trolley-0.1.3-noarch-unraid.txz
    installpkg /boot/extra/trolley-0.1.3-noarch-unraid.txz

You may need to reopen your terminal session after installing.

## Usage

    usage: trolley [-h] [-v] {install,info,remove,list,search,update} ...

    A simple package tool for Slackware, designed for unRAID

    positional arguments:
      {install,info,remove,list,search,update}
        install             Install a package by name
        info                Get info about a package
        remove              Remove installed package by name
        list                List installed packages
        search              Find a package by name
        update              Update trolley

    optional arguments:
      -h, --help            show this help message and exit
      -v, --version         Show version

Tips

* If you do not want a package to be installed on reboot, remove it from `/boot/extra`.
* If you do not specify a package version on install, the newest available package will be used. That package will be from Slackware 14.0. **Be Careful**.

## Examples

Versions are listed in descending slackware versions (14.0, 13.37, 13.1).

Search an exact name

    ~# trolley search git
    git (1.7.12.1, 1.7.4.4, 1.7.1)

Search with a name fragment

    ~# trolley search open
    Package Name (Slackware 14.0, 13.37, 13.1)
    ==========================================
    -video-openchrome (0.2.906, 0.2.904, 0.2.904)
    openvpn (2.2.2, 2.1.4, 2.1.1)
    openssl-solibs (1.0.1c, 0.9.8r, 0.9.8n)
    openssl (1.0.1c, 0.9.8r, 0.9.8n)
    openexr (1.7.0, 1.7.0, 1.6.1)
    openssh (6.1p1, 5.8p1, 5.5p1)
    openobex (1.5, 1.5, 1.5)
    openldap-client (2.4.31, 2.4.23, 2.4.21)

Install a package

    ~# trolley install git
    Downloading git 1.7.12.1
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

Install from packages.json (See Batch Package Installs for more info)

    ~# trolley install
    Downloading git 1.7.12.1
    Downloading nano 2.2.4

List installed packages

    ~# trolley list
    gcc (4.5.2)
    nano (2.2.4)
    PlexMediaServer (0.9.7.28.33)

Find an installed package

    ~# trolley list plex
    PlexMediaServer (0.9.7.28.33)

Remove all packages called curl (assuming curl 7.27.0 and 7.20.1 installed)

    ~# trolley remove curl
    Removing package /var/log/packages/curl-7.27.0-i486-2...
    Removing files:
    ...
    Removed curl 7.27.0

    Removing package /var/log/packages/curl-7.20.1-i486-1...
    Removing files:
    ...
    Removed curl 7.20.1

Remove a specific package version

    ~# trolley remove curl 7.27.0
    Removing package /var/log/packages/curl-7.27.0-i486-2...
    Removing files:
    ...
    Removed curl 7.27.0

## Batch Package Installs

Trolley supports using a `packages.json` file as a convenient way to specify dependencies for your plugin or project. Only exact version strings are supported (no version constraints).

**Note:** If the user already has a package by the same name installed, the specified package will not be downloaded, even if the existing package is newer or older.

Example:

```json
{
  "gcc": "4.5.2",
  "openssl": "1.0.1c",
  "nano": "2.2.4"
}
```

Then run `trolley install` in the same directory as `packages.json`. Profit.

## License

MIT. See LICENSE.txt for details.

## Development

This app uses [slackpack](https://github.com/nicinabox/slackpack) for packaging.
