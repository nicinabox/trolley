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
      regex = %r{
        (?<package_name>
          (?<file_name>
            (?<name> .+)-
            (?<version> .+)-
            (?<arch> .+)-
            (?<build>\w+)
          )
          \.?(?:t\wz)?
        )
      }x

      info = regex.match(package)
      keys = info.names.map { |k| k.to_sym }
      pkg  = ::Hash[keys.zip(info.captures)]
      pkg.merge(
        x64: pkg[:arch] == 'x86_64'
      )
    end

  end
end
