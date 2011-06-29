module NinjaModel
  class Base
    class_inheritable_accessor :primary_key
    self.primary_key = :id
    undef_method(:id) if method_defined?(:id)
  end

  module Identity
    def to_model
      self
    end

    def to_param
      send(self.class.primary_key).to_s if persisted?
    end

    def to_key
      key = nil
      key = send(self.class.primary_key) if persisted?
      [key] if key
    end
  end
end
