module NinjaModel
  module Associations
    class HasManyAssociation < CollectionAssociation

      #def insert_record(record, validate = true, raise = false)
      #  set_owner_attributes(record)

      #  if raise
      #    record.save!(:validate => validate)
      #  else
      #    record.save(:validate => validate)
      #  end
      #end

      #def association_scope
      #  scope = super
      #  scope = scope.where(reflection.foreign_key => owner.send(reflection.primary_key))
      #  scope
      #end
    end
  end
end
