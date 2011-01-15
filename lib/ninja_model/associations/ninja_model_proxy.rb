module NinjaModel
  module Associations
    class NinjaModelProxy
      attr_reader :proxy_klass
      def initialize(active_record)
        @klass = active_record
        @klass.class_eval do
          def ninja_proxy
            @ninja_proxy ||= begin
              self.class.ninja_proxy.instance(self)
            end
            @ninja_proxy.attributes = self.attributes.delete_if { |k,v| k.eql?('id') }
            @ninja_proxy
          end
        end

        @proxy_klass = active_record.parent.const_set("#{@klass.model_name}Proxy", Class.new(NinjaModel::Base))

        @klass.columns_hash.each_pair do |k,v|
          @proxy_klass.send :attribute, k, v.type, v.default, @proxy_klass
        end
      end

      def instance(obj)
        proxy = @proxy_klass.new
        proxy.send :instantiate, {'attributes' => obj.attributes}
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
