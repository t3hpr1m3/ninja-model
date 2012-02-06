require 'active_model'
require 'active_support/core_ext'

module NinjaModel
  extend ActiveSupport::Autoload

  class NinjaModelError < StandardError; end

  class << self
    attr_accessor :logger

    def set_logger(logger)
      ::NinjaModel.logger = logger
    end

    def ninja_model?(symbol)
      klass = symbol.to_s.camelize
      klass = klass.singularize
      klass = klass.constantize
      klass.ancestors.include?(NinjaModel::Base)
    end

    def configuration
      @config ||= ActiveSupport::OrderedOptions.new
    end
  end

  autoload :Attribute
  autoload :AttributeMethods
  autoload :Associations
  autoload :Adapters
  autoload :Base
  autoload :Callbacks
  autoload :Identity
  autoload :Persistence
  autoload :Predicate
  autoload :Reflection
  autoload :Relation
  autoload :Validation
end

if defined?(Rails)
  require 'ninja_model/railtie'
end
