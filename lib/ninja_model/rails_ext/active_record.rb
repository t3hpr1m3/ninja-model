require 'active_record'

module ActiveRecord
  module Associations
    module ClassMethods
      def has_one(association_id, options = {})
        if ninja_model?(:has_one, options[:class_name] || association_id)
          ninja_proxy.handle_association(:has_one, association_id, options)
        else
          super
        end
      end

      def ninja_proxy
        read_inheritable_attribute(:ninja_proxy) || write_inheritable_attribute(:ninja_proxy, NinjaModel::Associations::NinjaModelProxy.new(self))
      end

      private

      def ninja_model?(macro, association)
        klass = association.to_s.camelize
        klass = klass.singularize unless [:has_one, :belongs_to].include?(macro)
        klass = klass.constantize
        klass.ancestors.include?(NinjaModel::Base)
      end
    end

    def method_missing(method, *args)
      begin
        super
      rescue NoMethodError => ex
        if self.class.read_inheritable_attribute(:ninja_proxy) && ninja_proxy.respond_to?(method)
          ninja_proxy.send(method, *args)
        else
          raise ex
        end
      end
    end
  end

  module Reflection
    module ClassMethods
      def reflect_on_association(association)
        if read_inheritable_attribute(:ninja_proxy) && ninja_proxy.proxy_klass.reflections.include?(association)
          ninja_proxy.proxy_klass.reflect_on_association(association)
        else
          super
        end
      end
    end
  end
end
