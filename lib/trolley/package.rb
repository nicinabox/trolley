require 'trolley/base'

module Trolley
  class Package
    include Trolley::Base

    attr_accessor :name, :versions, :version

    def initialize(data, target_version_string = nil)
      @name           = data['name']
      @versions       = data['versions']
      @version        = matched_version(target_version_string)
    end

  private

    def matched_version(target_version_string)
      version = versions.select { |v|
        v['version'] == target_version_string
      }
      return version.last if version.any?

      versions.last
    end

  end
end
