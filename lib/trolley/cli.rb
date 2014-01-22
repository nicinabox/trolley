require 'rubygems'
require 'bundler'
require 'httparty'
require 'thor'
require 'trolley/helpers'

module Trolley
  class CLI < Thor
    include HTTParty
    include Trolley::Helpers

    base_uri 'http://slackware-packages.herokuapp.com'
    format :json

    desc "search [NAME]", "Searches for matching packages"
    def search(name = nil)
      packages =  if name
                    self.class.get("/packages?q=#{name}")
                  else
                    self.class.get("/packages")
                  end

      print_table packages.map {|pkg|
        pkg = stringify_keys(pkg)
        [pkg['name']]
      }
    end

    desc "list [NAME]", "List installed packages"
    def list(name = nil)
      packages = installed.map do |p|
        info = details(p)
        [info[:name], info[:version]]
      end

      if name
        print_table packages.select { |p|
          /#{name}/ =~ p.first
        }
      else
        print_table packages
      end
    end

    desc "install NAME", "Install a new package"
    def install(name, version_string = nil)
      package = self.class.get("/packages/#{name}")

      if package.any?
        version = if version_string
                    package['versions'].select { |v|
                      v['version'] == version_string
                    }.last
                  else
                    package['versions'].first
                  end

        status "Downloading #{package['name']} (#{version['version']})"

        FileUtils.mkdir_p '/boot/extra'
        File.open("/boot/extra/#{version['file_name']}", "wb") do |f|
          f.write self.class.get("http://slackware.cs.utah.edu/pub#{version['path']}")
        end

        status "Installing"

        if unraid? and not installed? version['tarball_name']
          `installpkg /boot/extra/#{version['file_name']}`
        end

        status "Installed"
      else

        status "No package named #{name}", :yellow
      end
    end

  end
end
