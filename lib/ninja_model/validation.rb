require 'active_model'

module NinjaModel
  module Validation
    extend ActiveSupport::Concern
    include ActiveModel::Validations

    included do
      define_model_callbacks :validation
      define_callbacks :validate, :scope => :name
    end

    def valid?
      run_callbacks :validation do
        super
      end
    end
  end
end
