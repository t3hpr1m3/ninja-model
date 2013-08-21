module NinjaModel
  module Serialization
    extend ActiveSupport::Concern
    include ActiveModel::Serializers::JSON

    def serializable_hash(options = nil)
      options = options.try(:clone) || {}

      hash = super(options)

      serializable_add_includes(options) do |association, records, opts|
        hash[association] = records.is_a?(Enumerable) ?
          records.map { |r| r.serializable_hash(opts) } :
          records.serializable_hash(opts)
      end

      hash
    end

    private

    def serializable_add_includes(options = {})
      return unless include_associations = options.delete(:include)

      base_only_or_except = { except: options[:except], only: options[:only] }

      include_has_options = include_associations.is_a?(Hash)
      associations = include_has_options ? include_associations.keys : Array.wrap(include_associations)

      associations.each do |association|
        records = case self.class.reflect_on_association(association).macro
        when :has_many, :has_and_belongs_to_many
          send(association).to_a
        when :has_one, :belongs_to
          send(association)
        end

        if records
          association_options = include_has_options ? include_associations[association] : base_or_only_except
          opts = options.merge(association_options)
          yield(association, records, opts)
        end
      end
    end
  end
end
