class Symbol
  NinjaModel::Predicate::PREDICATES.each do |predicate|
    define_method(predicate) do
      NinjaModel::Predicate.new(self, predicate)
    end
  end
end
