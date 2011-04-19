require 'active_support'

module NinjaModel
  module Persistence
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods

    module ClassMethods
      def get(rel)
      end

      def persist_with(adapter)

      end
    end

    included do
      class_inheritable_accessor :persistence_adapter
    end

    def save(*)
      if changed?
        run_callbacks :save do
          result = new_record? ? create : update
          changed_attributes.clear if result
          result
        end
      end
    end

    def create
      run_callbacks :create do
        if self.class.adapter.create(self)
          @persisted = true
        end
        @persisted
      end
    end

    def update
      self.class.adapter.update(self)
    end

    def new_record?
      !@persisted
    end

    def destroyed?
      @destroyed
    end

    def persisted?
      @persisted && !destroyed?
    end

    def destroy
      if self.class.adapter.destroy(self)
        @destroyed = true
      end
      @destroyed
    end

    def reload
      self.class.adapter.reload(self)
    end

    def update_attributes(attributes)
      self.attributes = attributes
      save
    end
  end
end
