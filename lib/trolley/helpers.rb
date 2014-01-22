require 'trolley/hash'

module Trolley
  module Helpers
    include Trolley::Hash

    def status(message, color = nil)
      say "=> #{message}", color
    end

    def unraid?
      /unraid/i =~ `uname -a`
    end

    def installed
      Dir['/var/log/packages/*'].map {|p|
        p.gsub('/var/log/packages/', '')
      }
    end

    def installed? (name)
      !!packages.find { |p| /#{name.downcase}/ =~ p }
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
