module NinjaModel

  module Validation
    extend ActiveSupport::Concern

    included do
      include ActiveModel::Validations
      define_model_callbacks :validation
    end

    def save(options={})
      perform_validations(options) ? super : false
    end

    def valid?(context = nil)
      context ||= (persisted? ? :update : :create)
      output = super(context)
      errors.empty? && output
    end

    protected

    def perform_validations(options)
      perform_validation = options[:validate] != false
      perform_validation ? valid?(options[:context]) : true
    end
  end
end
