module NinjaModel
  module Asociations
    class BelongsToAssociation
      def initialize(owner, reflection)
        @owner, @reflection = owner, reflection
        @relation = reflection.klass.scoped.where(:id => owner.send reflection.primery_key_name).first
      end
    end
  end
end
