module NinjaModel
  module Persistence
    extend ActiveSupport::Concern

    included do
      define_model_callbacks :save, :create, :update, :destroy, :reload
    end

    module InstanceMethods
      def save(*)
        run_callbacks :save do
          result = new_record? ? create : update
          changed_attributes.clear if result
          result
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
        run_callbacks :update do
          self.class.adapter.update(self)
        end
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
        run_callbacks :destroy do
          if self.class.adapter.destroy(self)
            @destroyed = true
          end
          @destroyed
        end
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
end
