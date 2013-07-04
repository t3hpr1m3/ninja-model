module NinjaModel

  module Validation
    extend ActiveSupport::Concern

    included do
      include ActiveModel::Validations
      include ActiveModel::Validations::Callbacks
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
      perform_validation = options[:validat] != false
      perform_validation ? valid?(options[:context]) : true
    end
  end
end
