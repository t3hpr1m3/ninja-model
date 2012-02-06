module NinjaModel
  module Associations
    class Association < ActiveRecord::Associations::Association

      def aliased_table_name
        raise NotImplementedError
      end

      def reset
        @loaded = false
        @target = nil
      end

      def load_target
        if find_target?
          @target ||= find_target
        end
        loaded! unless loaded?
        target
      rescue NinjaModel::RecordNotFound
        reset
      end

      def interpolate(sql, record = nil)
        raise NotImplementedError
      end

      def association_scope
        if klass
          @association_scope ||= begin
            scope = klass.unscoped
            scope = scope.extending(*Array.wrap(options[:extend]))
            scope = scope.apply_finder_options(options.slice(
              :readonly, :include, :order, :limit, :joins, :group, :having, :offset))
            scope
          end
        end
      end

      private

      def creation_attributes
        if options[:through]
          raise NotImplementedError, "NinjaModel does not support through associations yet."
        else
          super
        end
      end
    end
  end
end
