require 'rubygems'
require 'bundler'
require 'trolley/helpers'

module Trolley
  module Base
    include Trolley::Helpers

    def all_installed
      Dir['/var/log/packages/*'].map { |p|
        p.gsub('/var/log/packages/', '')
      }.sort { |a, b| a <=> b }
    end

    def installed? (name)
      !!all_installed.find { |p| /#{name.downcase}/ =~ p }
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
      File.readlines(env_path).each do |line|
        values = line.split("=")
        ENV[values[0]] = values[1].strip
      end if unraid?
    end

  private

    def env_path
      "/usr/local/boiler/trolley/env"
    end

  end
end

if Trolley::Helpers.unraid?
  Dir.chdir File.expand_path('../..', __FILE__) do
    Bundler.setup(:default)
  end
end
