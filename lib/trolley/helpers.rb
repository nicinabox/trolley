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
