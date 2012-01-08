require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
end
#Bundler.require(:default)
require 'rspec/core'
require 'ninja-model'

Dir[File.join(File.expand_path('../', __FILE__), 'support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :mocha
end

class DummyLogger
  def debug(*args)
  end
  def warn(*args)
  end
end

NinjaModel.set_logger(DummyLogger.new)
