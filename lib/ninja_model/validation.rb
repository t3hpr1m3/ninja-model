require 'active_model'

module NinjaModel
  module Validation
    extend ActiveSupport::Concern
    include ActiveModel::Validations

    def save(options={})
      run_callbacks :validation do
        perform_validations(options) ? super : false
      end
    end

    def valid?(context = nil)
      context ||= (persisted? ? :update : :create)
      output = super(context)
      errors.empty? && output
    end

    protected

    def perform_validations(options={})
      perform_validation = case options
        when Hash
          options[:validate] != false
        else
          ActiveSupport::Deprecation.warn "save(#{options}) is deprecated, please give save(:validate => #{options}) instead", caller
          options
        end

      if perform_validation
        valid?(options.is_a?(Hash) ? options[:context] : nil)
      else
        true
      end
    end
  end
end
