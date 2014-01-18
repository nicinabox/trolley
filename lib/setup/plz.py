#!/usr/bin/env python

import sys
import json
import urllib2
import shelx
import subprocess

class Plz(object):
  def __init__(self, arg):
    self.host = 'http://slackware.cs.utah.edu/pub/slackware'
    self.api  = 'http://slackware-packages.herokuapp.com/package'
    self.target_dir = '/boot/extra'

    self.arg      = arg
    self.command  = arg[1]
    self.name     = arg[2]
    self.version  = arg[3]

  def install(self):
    if not _installed():
      _download()
      _installpkg()

  def _installpkg(self):
    file = _path(self.target_dir, self.pkg['file_name'])
    subprocess.call(['installpkg', file])

  def _download(self):
    api = _path([self.api, self.name, self.version])
    self.pkg = _get(api)
    local_pkg  = _path([self.target_dir, self.pkg['file_name']])

    if not os.path.isfile(local_pkg):
      _wget(_path([self.host, self.pkg['path']]))

  def _installed(self):
    return self.pkg['package_name'] in _raw_installed_packages

  def _raw_installed_packages():
    return os.listdir('/var/log/packages/')

  def _wget(self, url):
    cmd = 'wget -Pq {0} {1}'.format(target_dir, url)
    subprocess.call(shlex.split(cmd))

  def _get(url):
    response = urllib2.urlopen(url)
    return json.load(response)

  def _path(list):
    return ('/').join(list)

# CLI
args = sys.argv
if len(args) == 4:
  plz = Plz(args)
  plz.install()
else:
  exit("Usage: plz install NAME VERSION")
