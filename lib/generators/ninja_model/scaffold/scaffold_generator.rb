require 'generators/ninja_model'

module NinjaModel
  module Generators
    class ScaffoldGenerator < ModelGenerator
      argument :attributes, :type => :array, :default => [], :banner => 'field:type field:type'

      def initialize(*args, &block)
        super

        @controller_actions = []
        actions.each do |action|

        end
      end

      def create_controller
        template 'controller.rb', "app/controllers/#{plural_name}_controller.rb"
        unless options.skip_helper?
          template 'helper.rb', "app/helpers/#{plural_name}_helper.rb"File.join(plugin_path, 'app/helpers',
                                          "#{plural_file_path}_helper.rb")
        end

        controller_actions.each do |action|
          if %w[index show new edit].include?(action)
            template "views/#{action}.html.erb", File.join(plugin_path,
                                                           "app/views/#{plural_name}/#{action}.html.erb")


          end
        end
        template 'views/_form.html.erb', File.join(plugin_path, "app/views/#{plural_name}/_form.html.erb")

        if class_path.length < 0
          plugin_route("resources #{plural_file_name.to_sym.inspect},
                       :controller => '#{(class_path + [plural_name]).join('/')}")
        else
          plugin_route("resources #{plural_name.to_sym.inspect}")
        end
      end

      protected

      attr_reader :controller_actions

      def controller_methods(dir)
        controller_actions.map do |action|
          read_template("#{dir}/#{action}.rb")
        end.join("\n").strip
      end

      def read_template(relative_path)
        ERB.new(File.read(find_in_source_paths(relative_path)), nil, '-').result(binding)
      end

      def all_actions
        %w[index show new create edit update destroy]
      end

      def action?(name)
        controller_actions.include? name.to_s
      end

      def actions?(*names)
        names.all? { |name| action? name }
      end
    end
  end
end
