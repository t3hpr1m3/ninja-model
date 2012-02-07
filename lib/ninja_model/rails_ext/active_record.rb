module ActiveRecord
  module NinjaModelExtensions
    module ReflectionExt
      extend ActiveSupport::Concern

      module ClassMethods
        def create_reflection(macro, name, options, active_record)
          klass = options[:class_name] || name
          klass = klass.to_s.camelize
          klass = klass.singularize if macro.in?([:has_many])
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

        def reflect_on_aggregation(aggregation)
          if reflections[aggregation].is_a?(NinjaModel::Reflection::AggregateReflection)
            reflections[aggregation]
          else
            super
          end
        end

        def reflect_on_association(association)
          if reflections[association].is_a?(NinjaModel::Reflection::AssociationReflection)
            reflections[association]
          else
            super
          end
        end
      end
    end
  end
end

module NinjaModel
  module ActiveRecordExtensions
    module ReflectionExt
      extend ActiveSupport::Concern

      module ClassMethods
        def create_reflection(macro, name, options, ninja_model)
          klass = options[:class_name] || name
          klass = klass.to_s.camelize
          klass = klass.singularize if macro.in?([:has_many])
          klass = compute_type(klass)
          if NinjaModel.ninja_model?(klass)
            super
          else
            case macro
            when :has_many, :belongs_to, :has_one
              reflection = ActiveRecord::Reflection::AssociationReflection.new(macro, name, options, ninja_model)
            when :composed_of
              reflection = ActiveRecord::Reflection::AggregateReflection.new(macro, name, options, ninja_model)
            else
              raise NotImplementedError, "NinjaModel does not currently support #{macro} associations."
            end
            self.reflections = self.reflections.merge(name => reflection)
          end
        end

        def reflect_on_aggregation(aggregation)
          if reflections[aggregation].is_a?(ActiveRecord::Reflection::AggregateReflection)
            reflections[aggregation]
          else
            super
          end
        end

        def reflect_on_association(association)
          if reflections[association].is_a?(ActiveRecord::Reflection::AssociationReflection)
            reflections[association]
          else
            super
          end
        end
      end
    end
  end
end

ActiveSupport.on_load(:ninja_model) do
  include NinjaModel::ActiveRecordExtensions::ReflectionExt
end
