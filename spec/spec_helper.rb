require 'bundler/setup'
Bundler.require(:default)
require 'rspec/core'

RSpec.configure do |config|
  config.mock_with :mocha
end
