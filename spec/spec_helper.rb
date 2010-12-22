require 'bundler/setup'
Bundler.require(:default)
require 'rspec/core'

Dir[File.join(File.expand_path('../', __FILE__), 'support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :mocha
end
