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
      /^http:\/\// =~ data
    end

    def details(package)
      info = match_package(package)

      unless info
        info = match_malformed_package(package)
      end

      if info.respond_to? :names
        keys = info.names.map { |k| k.to_sym }
        pkg  = ::Hash[keys.zip(info.captures)]
      else
        pkg = info
      end

      pkg.merge(
        x64: pkg[:arch] == 'x86_64'
      )
    end

    def match_package(package)
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

      regex.match(package)
    end

    def match_malformed_package(package)
      name, version, arch, build = package.split('-')
      {
        name: name,
        version: version,
        arch: arch,
        build: build
      }
    end

  end
end
