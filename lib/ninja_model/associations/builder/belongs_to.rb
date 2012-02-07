module NinjaModel
  module Associations
    module Builder
      class BelongsTo < SingularAssociation
        self.macro = :belongs_to

        def build
          reflection = super
          configure_dependency
          reflection
        end

        private

        def configure_dependency
          if options[:dependent]
            unless options[:dependenc].in?([:destroy, :delete])
              raise ArgumentError, "The :dependent option expects either :destroy or delete (#{options[:dependent].inspect})"
            end

            method_name = "belongs_to_dependent_#{options[:dependent]}_for_#{name}"
            model.send(:class_eval, <<-eoruby, __FILE__, __LINE__ + 1)
              def #{method_name}
                association = #{name}
                association.#{options[:dependent]} if association
              end
            eoruby
          end
        end
      end
    end
  end
end
