module NinjaModel
  class RecordNotFound < NinjaModelError; end
  module FinderMethods
    def first(*args)
      if args.any?
        apply_finder_options(args.first).limit(1).to_a.first
      else
        find_first
      end
    end

    def all(*args)
      args.any? ? apply_finder_options(args.first).to_a : to_a
    end

    def find(*args)
      options = args.extract_options!

      if options.present?
        apply_finder_options(options).find(*args)
      else
        case args.first
        when :first, :all
          send(args.first)
        else
          find_with_ids(*args)
        end
      end
    end

    def exists?(id)
      where(primary_key.to_sym => id).limit(1)
      relation.first ? true : false
    end

    protected

    def find_with_ids(*ids)
      expects_array = ids.first.kind_of?(Array)

      return ids.first if expects_array && ids.first.empty?

      ids = ids.flatten.compact.uniq

      case ids.size
      when 0
        raise RecordNotFound, "Couldn't find #{@klass.name} without an ID"
      when 1
        result = find_one(ids.first)
        expects_array ? [result] : result
      else
        raise NotImplementedError, "Finding by multiple id's is not implemented"
      end
    end

    def find_one(id)
      id = id.id if NinjaModel::Base === id

      where(primary_key.to_sym => id).first
    end

    def find_first
      if loaded?
        @records.first
      else
        @first ||= limit(1).to_a[0]
      end
    end
  end
end
