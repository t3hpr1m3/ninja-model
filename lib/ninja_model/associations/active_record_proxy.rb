
module NinjaModel
  module Associations
    class ActiveRecordProxy
      def initialize(ninja_model)
        @klass = ninja_model
        @klass.class_eval do
          def proxy
            @proxy ||= begin
              self.class.proxy.instance(self)
            end
            @proxy.attributes = self.attributes.delete_if { |k,v| k.eql?('id') }
            @proxy
          end
        end

        @proxy_klass = ninja_model.parent.const_set("#{@klass.model_name}Proxy", Class.new(ActiveRecord::Base))
        @proxy_klass.class_eval do
          cattr_accessor :columns
          self.columns = []
          def self.column(name, sql_type = nil, default = nil)
            self.columns << ActiveRecord::ConnectionAdapters::Column.new(name, nil, sql_type.to_s, default)
          end
        end

        @klass.model_attributes.each do |attr|
          @proxy_klass.send :column, attr.name, attr.type, attr.default
        end
      end

      def instance(obj)
        proxy = @proxy_klass.new
        proxy.send :init_with, {'attributes' => obj.attributes}
        proxy
      end

      def handle_association(macro, association_id, options)
        unless macro.eql?(:belongs_to)
          options = {:foreign_key => derive_foreign_key}.merge(options)
        end

        @proxy = nil
        @proxy_klass.send macro, association_id, options
      end

      private

      def derive_foreign_key
        "#{@klass.name.underscore}_id".to_sym
      end
    end
  end
end
