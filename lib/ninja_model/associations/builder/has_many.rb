module NinjaModel
  module Associations
    module Builder
      class HasMany < CollectionAssociation
        self.macro = :has_many

        self.valid_options += [:primary_key]
      end
    end
  end
end
