require 'trolley/base'

module Trolley
  class Package
    include Trolley::Base

    attr_accessor :name, :versions, :version

    def initialize(data, target_version_string = nil)
      @target_version_string = target_version_string

      @name           = data['name']
      @versions       = data['versions']
      @version        = matched_version
    end

  private

    def matched_version
      target = Gem::Dependency.new(name, @target_version_string)

      version = versions.select do |v|
        potential = Gem::Dependency.new(name, v['version'])
        target =~ potential and v['x64'] == x64?
      end

      if version.empty?
        raise Exception, "No matching #{arch} version of #{name} #{@target_version_string}"
      else
        version.last
      end
    end

    def x64?
      'x86_64' == arch
    end

    def arch
      `uname -m`.strip
    end

  end
end
