require 'active_record/associations'
require 'active_record/reflection'

module ActiveRecord
  module Associations
    module ClassMethods
      def has_one_with_ninja_model(association_id, options = {})
        if ninja_model?(:has_one, options[:class_name] || association_id)
          ninja_proxy.handle_association(:has_one, association_id, options)
        else
          has_one_without_ninja_model(association_id, options)
        end
      end
      alias_method_chain :has_one, :ninja_model

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
      def reflect_on_association_with_ninja_model(association)
        if read_inheritable_attribute(:ninja_proxy) && ninja_proxy.proxy_klass.reflections.include?(association)
          ninja_proxy.proxy_klass.reflect_on_association(association)
        else
          reflect_on_association_without_ninja_model(association)
        end
      end
      alias_method_chain :reflect_on_association, :ninja_model
    end
  end
end
