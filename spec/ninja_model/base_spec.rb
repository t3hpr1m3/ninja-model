require 'spec_helper'

describe NinjaModel::Base do
  it_should_behave_like "ActiveModel"
  before(:each) do
    @klass = Class.new(NinjaModel::Base) do
    end
    @klass.send :attribute, :width, :integer
    @klass.send :attribute, :height, :integer
    @klass.send :attribute, :color, :string
  end

  it 'should return a configuration path' do
    Rails.stubs(:root).returns('/')
    @klass.configuration_path.should be_kind_of(String)
  end

  it 'should accept a configuration path' do
    @klass.configuration_path = 'foo'
    @klass.configuration_path.should eql('foo')
  end

  it 'should return NinjaModel\'s logger' do
    logger = mock('logger')
    NinjaModel.stubs(:logger).returns(logger)
    @klass.logger.should eql(logger)
  end

  it { @klass.should respond_to(:logger) }

  it 'should generate a relation' do
    @klass.relation.should be_kind_of(NinjaModel::Relation)
  end

  it 'should instantiate from an existing data structure' do
    attrs = {:width => 100, :height => 200, :color => 'red'}
    @obj = @klass.new
    @obj.instantiate(attrs)
    @obj.attributes[:width].should eql(100)
  end

  it 'should return a configuration' do
    @klass.stubs(:configuration_path)
    IO.stubs(:read).returns('foo: bar')
    @klass.configuration.should be_kind_of(Hash)
    @klass.configuration[:foo].should eql('bar')
  end

  describe 'scoping' do
    it 'should return a stock relation for unscoped' do
      @klass.unscoped.predicates.should be_empty
      @klass.unscoped.limit_value.should be_nil
      @klass.unscoped.offset_value.should be_nil
      @klass.unscoped.ordering.should be_empty
      @klass.unscoped.predicates.should be_empty
    end

    it 'should handle default scoping' do
      @klass.default_scope(@klass.where(:width => 100))
      rel = @klass.default_scoping.first
      rel.should be_kind_of(NinjaModel::Relation)
      rel.predicates.first.should be_kind_of(NinjaModel::Predicate)
      rel.predicates.first.value.should eql(100)
    end
  end
end
