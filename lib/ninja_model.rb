require 'active_support'
require 'active_support/core_ext/hash/indifferent_access'

module NinjaModel
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :Adapters
  autoload :Associations
  autoload :Attributes
  autoload :Callbacks
  autoload :Configuration
  autoload :Identity
  autoload :Persistence
  autoload :Predicate
  autoload :Reflection
  autoload :Relation
  autoload :Scoping
  autoload :Validation

  autoload_under 'relation' do
    autoload :QueryMethods
    autoload :FinderMethods
    autoload :SpawnMethods
  end


  class << self
    attr_accessor :logger

    def set_logger(logger)
      ::NinjaModel.logger = logger
    end
  end
end

require 'ninja_model/railtie'
require 'ninja_model/errors'
