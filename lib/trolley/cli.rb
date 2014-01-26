require 'trolley/base'
require 'trolley/package'
require 'httparty'
require 'thor'

module Trolley
  class CLI < Thor
    include HTTParty
    include Trolley::Base

    base_uri 'http://slackware-packages.herokuapp.com'
    format :json

    def initialize(*args)
      super
      load_env_vars
    end

    desc "search [NAME]", "Searches for matching packages"
    def search(name = nil)
      packages =  if name
                    self.class.get("/packages?q=#{name}")
                  else
                    self.class.get("/packages")
                  end

      print_in_columns packages.map {|pkg|
        pkg['name']
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

    desc "install NAME [VERSION]", "Install a new package"
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
          f.write HTTParty.get("http://slackware.cs.utah.edu/pub#{version['path']}")
        end

        status "Installing"

        if unraid? and not installed? version['tarball_name']
          `installpkg /boot/extra/#{version['file_name']}`
        end

        status "Installed", :green
      else

        status "No package named #{name}", :yellow
      end
    end

    desc "remove NAME", "Remove a package"
    def remove(name)
      if yes? "Really remove #{name}?"
        `removepkg #{name}`
        status "#{name} removed", :green
      end
    end

    desc "info NAME [VERSION]", "Show package details"
    def info(name, version_string = nil)
      package = self.class.get("/packages/#{name}")

      if version_string
        version = package['versions'].select {|v| v['version'] == version_string }.last
        info = [
          ['Name', package['name']],
          ['Summary', version['summary']],
          ['Version', version['version']],
          ['Arch', version['arch']],
          ['Build', version['build']],
          ['Size', "#{version['size_uncompressed']} (#{version['size_compressed']} compressed)"],
          ['Slackware', version['slackware']],
          ['Patch', version['patch'] ? "yes" : "no"]
        ]
      else
        info = [
          ['Name', package['name']],
          ['Summary', package['versions'].last['summary']],
          ['Versions', package['versions'].map { |v| v['version'] }.uniq.join(', ')]
        ]
      end

      print_table info
    end

    desc "version", "Show Trolley version"
    def version
      puts manifest['version']
    end
  end
end
