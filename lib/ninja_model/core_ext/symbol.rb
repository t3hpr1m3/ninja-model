class Symbol
  NinjaModel::Predicate::PREDICATES.each do |predicate|
    define_method(predicate) do |*args|
      NinjaModel::Predicate.new(self, predicate, *args)
    end
  end
end
