require 'trolley/base'

module Trolley
  class Package
    include Trolley::Base

    attr_accessor :name, :versions, :version

    def initialize(data, target_version_string = nil)
      @target_version_string = target_version_string

      if url? data
        package_name = File.basename(data)
        info         = stringify_keys details package_name
        @name        = info['name']
        @version     = info
      else
        @name      = data['name']
        @versions  = data['versions']
        @version   = matched_version
      end

      @version['arch_ok'] = x64?(@version['arch']) == x64?
    end

  private

    def matched_version
      target = Gem::Dependency.new(name, @target_version_string)

      version = versions.select do |v|
        potential = Gem::Dependency.new(name, v['version'])

        target =~ potential and
        v['x64'] == x64? and
        from_os?(v)
      end

      if version.empty?
        raise Exception, "No matching #{arch} version of #{name} #{@target_version_string}"
      else
        version.last
      end
    end

    def from_os?(version)
      if @target_version_string
        # If target version, use version's slackaware
        !!version['slackware']

      else
        # If no target version, use current slackware
        /#{version['slackware']}/ =~ slackware
      end
    end

    def x64?(version_arch)
      'x86_64' == version_arch || arch
    end

    def slackware
      if unraid?
        if File.exists?('/etc/slackware-version')
          version_string = File.read('/etc/slackware-version').strip
          version_string.match(/[\d\.]+$/)[0]
        else
          '13.1'
        end
      end
    end

  end
end
