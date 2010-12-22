module NinjaModel
  module FinderMethods
    def first(*args)
      if args.any?
      else
        find_first
      end
    end

    protected

    def find_first
      if loaded?
        @records.first
      else
        @first ||= limit(1).to_a[0]
        puts "to_a returned: #{@first}"
        @first
      end
    end
  end
end
