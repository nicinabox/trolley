require 'trolley/hash'

module Trolley
  module Helpers
    include Trolley::Hash

    def status(message, color = nil)
      say "=> #{message}", color
    end

    def manifest
      path = ENV['TROLLEY_MANIFEST_PATH']
      file =  if path
                File.join(path, 'boiler.json')
              else
                File.join('boiler.json')
              end
      JSON.parse File.read file
    end

    def load_env_vars
      File.readlines("/usr/local/boiler/trolley/env").each do |line|
        values = line.split("=")
        ENV[values[0]] = values[1].strip
      end if unraid?
    end

    def unraid?
      /unraid/i =~ `uname -a`
    end

    def unraid?
      /unraid/i =~ `uname -a`
    end
    module_function :unraid?

    def installed
      Dir['/var/log/packages/*'].map {|p|
        p.gsub('/var/log/packages/', '')
      }.sort { |a, b| a <=> b }
    end

    def installed? (name)
      !!installed.find { |p| /#{name.downcase}/ =~ p }
    end

    def details(package)
      regex = /(.+)-(.+)-(.+)-(.+)/
      info  = regex.match(package)

      {
        name:    info[1],
        version: info[2],
        arch:    info[3],
        build:   info[4]
      }
    end

  end
end
