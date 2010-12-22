module NinjaModel
  module FinderMethods
    def first(*args)
      if args.any?
      else
        find_first
      end
    end

    def last(*args)
      if args.any?
      else
      end
    end

    def all(*args)
      args.any? ? apply_finder_options(args.first).to_a : to_a
    end

    protected

    def find_first
      if loaded?
        @records.first
      else
        @first ||= limit(1).to_a[0]
      end
    end
  end
end
