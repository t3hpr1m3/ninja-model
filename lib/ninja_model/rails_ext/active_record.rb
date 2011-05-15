require 'active_record'
require 'active_record/associations'
require 'active_record/reflection'

module ActiveRecord
  module Associations
    module ClassMethods
      def has_one_with_ninja_model(association_id, options = {})
        if NinjaModel.ninja_model?(options[:class_name] || association_id)
          ninja_proxy.handle_association(:has_one, association_id, options)
        else
          has_one_without_ninja_model(association_id, options)
        end
      end
      alias_method_chain :has_one, :ninja_model

      def ninja_proxy
        read_inheritable_attribute(:ninja_proxy) || write_inheritable_attribute(:ninja_proxy, NinjaModel::Associations::NinjaModelProxy.new(self))
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

module NinjaModel
  class Base
    class << self
      def has_one_with_active_record(association_id, options = {})
        if ninja_model?(:has_one, options[:class_name] || association_id)
          has_one_without_active_record(association_id, options)
        else
          proxy.handle_association(:has_one, association_id, options)
        end
      end

      alias_method_chain :has_one, :active_record

      def belongs_to_with_active_record(association_id, options = {})
        if ninja_model?(:belongs_to, options[:class_name] || association_id)
          belongs_to_without_active_record(association_id, options)
        else
          proxy.handle_association(:belongs_to, association_id, options)
        end
      end

      alias_method_chain :belongs_to, :active_record

      def has_many_with_active_record(association_id, options = {})
        if ninja_model?(:has_many, association_id)
          has_many_without_active_record(association_id, options)
        else
          proxy.handle_association(:has_many, association_id, options)
        end
      end

      alias_method_chain :has_many, :active_record

      def proxy
        read_inheritable_attribute(:proxy) || write_inheritable_attribute(:proxy, Associations::ActiveRecordProxy.new(self))
      end
    end

    def method_missing(method, *args)
      if self.class.read_inheritable_attribute(:proxy) && proxy.respond_to?(method)
        proxy.send(method, *args)
      else
        super
      end
    end
  end

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
