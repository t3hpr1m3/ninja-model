require 'active_record'

module ActiveRecord
  class Base
    class << self
      def create_reflection(macro, name, options, active_record)
        klass = options[:class_name] || name
        klass = klass.to_s.camelize
        klass = klass.singularize
        klass = compute_type(klass)
        if NinjaModel.ninja_model?(klass)
          case macro
          when :has_many, :belongs_to, :has_one
            reflection = NinjaModel::Reflection::AssociationReflection.new(macro, name, options, active_record)
          else
            raise NotImplementedError, "NinjaModel does not currently support #{macro} associations."
          end
          self.reflections = self.reflections.merge(name => reflection)
          reflection
        else
          super
        end
      end

      #def has_one_with_ninja_model(association_id, options = {})
      #  klass = options[:class_name] || association_id
      #  klass = klass.to_s.camelize
      #  klass = klass.singularize
      #  klass = compute_type(klass)
      #  if NinjaModel.ninja_model?(klass)
      #    ninja_proxy.handle_association(:has_one, association_id, options.merge({:class_name => klass.name}))
      #  else
      #    has_one_without_ninja_model(association_id, options)
      #  end
      #end
      #alias_method_chain :has_one, :ninja_model

      #def has_many_with_ninja_model(association_id, options = {})
      #  klass = options[:class_name] || association_id
      #  klass = klass.to_s.camelize
      #  klass = klass.singularize
      #  klass = compute_type(klass)
      #  if NinjaModel.ninja_model?(klass)
      #    ninja_proxy.handle_association(:has_many, association_id, options.merge({:class_name => klass.name}))
      #  else
      #    has_many_without_ninja_model(association_id, options)
      #  end
      #end
      #alias_method_chain :has_many, :ninja_model

      #def reflect_on_association_with_ninja_model(association)
      #  if read_inheritable_attribute(:ninja_proxy) && ninja_proxy.proxy_klass.reflections.include?(association)
      #    ninja_proxy.proxy_klass.reflect_on_association(association)
      #  else
      #    reflect_on_association_without_ninja_model(association)
      #  end
      #end

      #alias_method_chain :reflect_on_association, :ninja_model

      #def ninja_proxy
      #  read_inheritable_attribute(:ninja_proxy) || write_inheritable_attribute(:ninja_proxy, NinjaModel::Associations::NinjaModelProxy.new(self))
      #end

    end

    #def method_missing(method, *args)
    #  begin
    #    super
    #  rescue NoMethodError => ex
    #    if self.class.read_inheritable_attribute(:ninja_proxy) && ninja_proxy.respond_to?(method)
    #      ninja_proxy.send(method, *args)
    #    else
    #      raise ex
    #    end
    #  end
    #end
  end
end

module NinjaModel

  class Base
    class << self
      def has_one_with_active_record(association_id, options = {})
        klass = options[:class_name] || association_id
        klass = klass.to_s.camelize
        klass = compute_type(klass)
        if NinjaModel.ninja_model?(klass)
          has_one_without_active_record(association_id, options.merge(:class_name => klass.name.underscore))
        else
          reflection = proxy.handle_association(:has_one, association_id, options)
          write_inheritable_hash :reflections, association_id => reflection
          reflection
        end
      end

      alias_method_chain :has_one, :active_record

      def belongs_to_with_active_record(association_id, options = {})
        klass = options[:class_name] || association_id
        klass = klass.to_s.camelize
        klass = compute_type(klass)
        if NinjaModel.ninja_model?(klass)
          belongs_to_without_active_record(association_id, options.merge(:class_name => klass.name.underscore))
        else
          reflection = proxy.handle_association(:belongs_to, association_id, options)
          write_inheritable_hash :reflections, association_id => reflection
          reflection
        end
      end

      alias_method_chain :belongs_to, :active_record

      def has_many_with_active_record(association_id, options = {})
        klass = options[:class_name] || association_id
        klass = klass.to_s.camelize.singularize
        klass = compute_type(klass)
        if NinjaModel.ninja_model?(klass)
          has_many_without_active_record(association_id, options.merge(:class_name => klass.name.underscore))
        else
          reflection = proxy.handle_association(:has_many, association_id, options)
          write_inheritable_hash :reflections, association_id => reflection
          reflection
        end
      end

      alias_method_chain :has_many, :active_record

      def reflect_on_association_with_active_record(association_id)
        if read_inheritable_attribute(:proxy) && proxy.proxy_klass.reflections.include?(association_id)
          proxy.proxy_klass.reflect_on_association(association_id)
        else
          reflect_on_association_without_active_record(association_id)
        end
      end

      alias_method_chain :reflect_on_association, :active_record

      def proxy
        read_inheritable_attribute(:proxy) || write_inheritable_attribute(:proxy, Associations::ActiveRecordProxy.new(self))
      end
    end

    def respond_to?(sym)
      if self.class.read_inheritable_attribute(:proxy) && proxy.respond_to?(sym)
        true
      else
        super
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
      attr_reader :proxy_klass
      def initialize(ninja_model)
        @klass = ninja_model
        @klass.class_eval do
          def proxy
            @proxy ||= begin
              self.class.proxy.instance(self)
            end
            @proxy.attributes = self.attributes.delete_if { |k,v| k.eql?('id') }
            @proxy.id = self.id if self.attributes.key?(:id)
            @proxy
          end
        end

        @proxy_klass = ninja_model.parent.const_set("#{@klass.model_name.gsub(/[^a-zA-Z]/, '')}Proxy", Class.new(ActiveRecord::Base))
        @proxy_klass.class_eval do
          cattr_accessor :columns
          self.columns = []
          def self.column(name, sql_type = nil, default = nil)
            self.columns << ActiveRecord::ConnectionAdapters::Column.new(name, nil, sql_type.to_s, default)
          end

          def self.columns_hash
            h = {}
            self.columns.each do |c|
              h[c.name] = c
            end
            h
          end
          def self.column_defaults
            self.columns_hash
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
        "#{@klass.name.demodulize.underscore}_id".to_sym
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
            @ninja_proxy.attributes = self.attributes
            @ninja_proxy
          end
        end

        @proxy_klass = active_record.parent.const_set("#{@klass.model_name.demodulize}Proxy", Class.new(NinjaModel::Base))

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
        "#{@klass.name.demodulize.underscore}_id".to_sym
      end
    end
  end
  
end
