require 'generators/ninja_model'

module NinjaModel
  module Generators
    class ModelGenerator < NamedBase
      argument :attributes, :type => :array, :default => [], :banner => 'field:type field:type'

      def initialize(*args, &block)
        super
      end

      def create_model
        template 'model.rb', "app/models/#{singular_name}.rb"
      end

      hook_for :test_framework, :as => :model
    end
  end
end
