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

    def save
      run_callbacks :save do
        create_or_update
      end
    end

    def create_or_update
      if new_record?
        create
      else
        update
      end
      true
    end

    def create
      run_callbacks :create do
        true
      end
    end

    def update
      run_callbacks :update do
        true
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
        true
      end
    end

    def reload
      true
    end
  end
end
