module NinjaModel
  class Base
    include ActiveModel::Validations
    define_model_callbacks :validation
  end

  module Validation

    def save(options={})
      run_callbacks :validation do
        valid?(options.is_a?(Hash) ? options[:context] : nil) ? super : false
      end
    end

    def valid?(context = nil)
      context ||= (persisted? ? :update : :create)
      output = super(context)
      errors.empty? && output
    end
  end
end
