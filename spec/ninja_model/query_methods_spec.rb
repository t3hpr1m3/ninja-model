require 'spec_helper'

describe NinjaModel::QueryMethods do
  before(:each) do
    @model = mock('model') do
      stubs(:model_attributes).returns({:valid => {}}.with_indifferent_access)
    end
    @rel = NinjaModel::Relation.new(@model)
  end

  describe 'order' do
    it 'should update the relations\'s order_values' do
      new_rel = @rel.order(:new_order)
      new_rel.ordering.first.should eql(:new_order)
    end
  end

  describe 'where' do
    it 'should update the relation\'s where_values' do
      new_rel = @rel.where(:valid => 2)
      new_rel.predicates.first.should be_kind_of(NinjaModel::Predicate)
      new_rel.predicates.first.value.should eql(2)
    end
  end

  describe 'limit' do
    it 'should update the relation\'s limit' do
      new_rel = @rel.limit(5)
      new_rel.limit_value.should eql(5)
    end
  end

  describe 'build_predicates' do
    it 'should reject a string' do
      lambda { @rel.send :build_predicates, 'foo < 1' }.should raise_error(ArgumentError)
    end

    describe 'with an array' do
      it 'should return an array of NinjaModel::Predicates' do
        res = @rel.send :build_predicates, [{:valid => 1}]
        res.should be_kind_of(Array)
        res.first.should be_kind_of(NinjaModel::Predicate)
        res.first.value.should eql(1)
      end
    end
    describe 'with a hash' do
      it 'should handle a valid symbol' do
        res = @rel.send :build_predicates, {:valid => 1}
        res.should be_kind_of(Array)
        res.first.should be_kind_of(NinjaModel::Predicate)
        res.first.value.should eql(1)
      end

      it 'should reject an invalid symbol' do
        lambda { @rel.send :build_predicates, {:invalid => 2} }.should raise_error(ArgumentError)
      end

      it 'should handle a predicate' do
        rel = NinjaModel::Predicate.new(:valid, :eq)
        res = @rel.send :build_predicates, {rel => 1}
        res.should be_kind_of(Array)
        res.first.should be_kind_of(NinjaModel::Predicate)
        res.first.value.should eql(1)
      end
      it 'should reject an unkrecognized key' do
        lambda { @rel.send :build_predicates, {'bad' => 12} }.should raise_error(ArgumentError)
      end
    end

    it 'should reject an unprocessable argument' do
      lambda { @rel.send :build_predicates, 5 }.should raise_error(ArgumentError)
    end

  end

end
