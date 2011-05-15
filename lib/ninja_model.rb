require 'rails/all'
require 'active_support/all'

module NinjaModel
  extend ActiveSupport::Autoload
  class NinjaModelError < StandardError; end

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

    def ninja_model?(symbol)
      klass = symbol.to_s.camelize
      klass = klass.singularize
      klass = klass.constantize
      klass.ancestors.include?(NinjaModel::Base)
    end

    def configuration
      Rails.application.config.ninja_model
    end
  end

  class Base
  end
end

require 'ninja_model/base'
require 'ninja_model/railtie'
