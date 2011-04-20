require 'active_support'
require 'active_support/core_ext/hash/indifferent_access'

module NinjaModel
  extend ActiveSupport::Autoload

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

require 'ninja_model/base'
#require 'ninja_model/configuration'
#require 'ninja_model/attributes'
#require 'ninja_model/errors'
#require 'ninja_model/associations'
#require 'ninja_model/rails_ext/active_record'
#require 'ninja_model/adapters'
#require 'ninja_model/callbacks'
#require 'ninja_model/identity'
#require 'ninja_model/persistence'
#require 'ninja_model/predicate'
#require 'ninja_model/reflection'
#require 'ninja_model/relation'
#require 'ninja_model/scoping'
#require 'ninja_model/validation'
require 'ninja_model/railtie'
