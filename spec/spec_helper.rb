require 'rubygems'
require 'bundler'
Bundler.setup
require "active_support/core_ext/hash/keys.rb"
require 'hoptoad_notifier'
require 'ht_retro.rb'

RSpec.configure do |config|
  config.color_enabled = true
end

HoptoadNotifier.configure do |hoptoad|
  hoptoad.api_key = 'somekey'
  hoptoad.host = 'someplace.com'
end