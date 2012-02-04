module NinjaModel
  module Callbacks
    extend ActiveSupport::Concern

    included do
      extend ActiveModel::Callbacks
    end
  end
end
