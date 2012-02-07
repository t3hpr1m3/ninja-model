module NinjaModel
  module Associations
    module Builder
      class HasOne < SingularAssociation
        self.macro = :has_one

        def constructable?
          true
        end

        private

        def validate_options
          valid_options = self.class.valid_options
          options.assert_valid_keys(valid_options)
        end
      end
    end
  end
end
