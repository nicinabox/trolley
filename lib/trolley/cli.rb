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
      packages = all_installed.map do |package_name|
        package = details(package_name)
        [package[:name], package[:version]]
      end

      if name
        print_table packages.select { |p|
          /#{name}/ =~ p.first
        }
      else
        print_table packages
      end
    end

    desc "install NAME [VERSION|latest]", "Install a new package"
    method_option :force, :type => :boolean, :aliases => "-f"
    def install(name, version_string = nil)
      if url? name
        package = Trolley::Package.new(name)
      else
        pkg = self.class.get("/packages/#{name}")
        unless pkg.any?
          status "No package named #{name}", :yellow
          return
        end

        begin
          package = Trolley::Package.new(pkg, version_string)
        rescue Exception => e
          status e, :red
          status "Try `trolley install #{name} latest` to install the latest"
          return
        end
      end

      version = package.version

      unless version['arch_ok']
        status "Sorry, can't install #{package.name} (#{version['version']} #{version['arch']}) on your arch", :red
        return
      end

      if !options[:force] and installed? version['file_name']
        status "Using #{package.name} (#{version['version']})"
        return
      end

      status "Downloading #{package.name} (#{version['version']} #{version['arch']})"

      FileUtils.mkdir_p '/boot/extra'

      # Remove old archive versions
      FileUtils.rm_rf Dir["/boot/extra/#{package.name}*"]

      # Write out this package
      File.open("/boot/extra/#{version['package_name']}", "wb") do |f|
        if url? name
          f.write HTTParty.get(name)
        else
          f.write HTTParty.get("http://slackware.cs.utah.edu/pub#{version['path']}")
        end
      end

      status "Installing"

      if unraid?
        `installpkg /boot/extra/#{version['package_name']}`

        if $?.exitstatus > 0
          status "There was an error installing #{package.name}", :red
          return
        end
      end

      status "Installed", :green
    end

    desc "update NAME [VERSION|latest]", "Update an existing package"
    def update(name, version_string = nil)
      invoke :install, [name, version_string], force: true
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
