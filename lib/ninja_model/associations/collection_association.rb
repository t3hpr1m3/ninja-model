module NinjaModel
  module Associations
    class CollectionAssociation < Association
      attr_reader :proxy
      delegate :select, :find, :first, :last, :count, :size, :length,
        :empty?, :any?, :to => :scoped

      def initialize(owner, reflection)
        super
        @proxy = CollectionProxy.new(self)
      end

      def reader(force_reload = false)
        if force_reload
          klass.uncached { reload }
        end
        proxy
      end

      def reset
        @loaded = false
        @target = []
      end

      #def find(*args)
      #  if block_given?
      #    load_target.find(*args) { |*block_args| yield(*block_args) }
      #  else
      #    scoped.find(*args)
      #  end
      #end

      def first(*args)
        first_or_last(:first, *args)
      end

      def last(*args)
        first_or_last(:last, *args)
      end

      def build(attributes = {}, options = {}, &block)
        if attributes.is_a?(Array)
          attributes.collect { |attr| build(attr, options, &block) }
        else
          add_to_target(build_record(attributes, options)) do |record|
            yield(record) if block_given?
          end
        end
      end

      #def create(attributes = {}, options = {}, &block)
      #  create_record(attributes, options, &block)
      #end

      #def create!(attributes = {}, options = {}, &block)
      #  create_record(attributes, options, true, &block)
      #end

      def add_to_target(record)
        yield(record) if block_given?
        @target << record
        record
      end

      private

      def find_target
        puts "find_target for #{self}"
        scoped.all
      end

      #def create_record(attributes, options, raise = false, &block)
      #  unless owner.persisted?
      #    raise ActiveRecord::RecordNotSaved, "You cannot call create unless the parent is saved"
      #  end

      #  if attributes.is_a?(Array)
      #    attributes.collect { |attr| create_record(attr, options, raise, &block) }
      #  else
      #    add_to_target(build_record(attributes, options)) do |record|
      #      yield(record) if block_given?
      #      insert_record(record, true, raise)
      #    end
      #  end
      #end

      #def insert_record(record, validate = true, raise = false)
      #  raise NotImplementedError
      #end

      def create_scope
        scoped.scope_for_create.stringify_keys
      end

      def first_or_last(type, *args)
        args.shift if args.first.is_a?(Hash) && args.first.empty?

        collection = scoped.all
        collection.send(type, *args)
      end
    end
  end
end
