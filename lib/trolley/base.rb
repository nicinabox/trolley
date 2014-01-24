require 'rubygems'
require 'bundler'
require 'trolley/helpers'

module Trolley
  module Base
    include Trolley::Helpers
  end
end

if Trolley::Helpers.unraid?
  Dir.chdir File.expand_path('../..', __FILE__) do
    Bundler.setup(:default)
  end
end
