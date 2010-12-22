require 'rails/generators'
require 'rails/generators/named_base'

module NinjaModel
  module Generators
    class NamedBase < Rails::Generators::NamedBase
      def self.source_root
        @ninja_model_source_root ||= File.join(File.dirname(__FILE__), 'ninja_model', generator_name, 'templates')
      end
    end
  end
end
