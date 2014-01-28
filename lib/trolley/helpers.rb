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
    module_function :unraid?

    def url?(data)
      return unless data.is_a? String
      /^http/ =~ data
    end

    def details(package)
      regex = /((.+)-(.+)-(.+)-(.+)(.t\wz)?)/
      info  = regex.match(package)

      {
        package_name: info[1],
        name:    info[2],
        version: info[3],
        arch:    info[4],
        build:   info[5]
      }
    end

  end
end
