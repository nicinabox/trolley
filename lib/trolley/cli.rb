require 'rubygems'
require 'bundler'
require 'httparty'
require 'thor'
require 'trolley/helpers'

module Trolley
  class CLI < Thor
    include HTTParty
    include Trolley::Helpers

    base_uri 'http://slackware-packages.herokuapp.com'
    format :json

    desc "search", "Searches for matching packages"
    def search(name = nil)
      packages =  if name
                    self.class.get("/packages?q=#{name}")
                  else
                    self.class.get("/packages")
                  end

      print_table packages.map {|pkg|
        pkg = stringify_keys(pkg)
        [pkg['name']]
      }
    end

    desc "list", "List installed packages"
    def list(name = nil)
      packages = installed.map do |p|
        info = details(p)
        [info[:name], info[:version]]
      end

      if name
        print_table packages.select { |p|
          /#{name}/ =~ p.first
        }
      else
        print_table packages
      end
    end

  end
end
