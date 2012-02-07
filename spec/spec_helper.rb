require 'rubygems'
require 'bundler'
require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
end
Bundler.require(:default, :test)

RSpec.configure do |config|
  config.mock_with :mocha
end


def init_active_record
  db_root = File.join(File.expand_path('../', __FILE__), 'db')
  ActiveRecord::Base.configurations['test'] = {
    'adapter' => 'sqlite3',
    'database' => File.join(db_root, 'test.sqlite3'),
    'pool' => 5,
    'timeout' => 5000
  }
  ActiveRecord::Base.establish_connection(:test)

  schema_file = File.join(File.expand_path('../', __FILE__), 'db', 'schema.rb')
  load schema_file
end

init_active_record

class DummyLogger
  def debug(*args)
    #puts "*** DEBUG ***"
    #puts args
  end
  def warn(*args)
    puts "*** WARNING ***"
    puts args
  end

  def error(*args)
    puts "*** ERROR ***"
    puts args
  end

  def debug?
    true
  end
end

NinjaModel.set_logger(DummyLogger.new)
ActiveRecord::Base.logger = DummyLogger.new

ActiveSupport::Dependencies.autoload_paths << File.join(File.expand_path('../', __FILE__), 'models')

Dir[File.join(File.expand_path('../', __FILE__), 'support/**/*.rb')].each { |f| require f }
