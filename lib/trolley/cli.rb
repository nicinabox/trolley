require 'rubygems'
require 'bundler'
require 'httparty'
require 'thor'

module Trolley
  class CLI < Thor
    include HTTParty

    base_uri 'http://slackware-packages.herokuapp.com'
    format :json

    desc "search", "Searches for matching packages"
    def search(name = nil)
      packages =  if name
                    self.class.get("/packages?q=#{name}")
                  else
                    self.class.get("/packages")
                  end

      print_table packages.map {|p| [p['name']] }
    end

  end
end
