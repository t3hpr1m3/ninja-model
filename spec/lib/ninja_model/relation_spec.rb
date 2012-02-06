require 'spec_helper'

describe NinjaModel::Relation do
  class RelationModel < NinjaModel::Base
    attribute :id, :integer, :primary_key => true
    attribute :attr1, :integer
    attribute :attr2, :string

    scope :foo, where(:attr2 => 'foo')
  end

  before {
    @rel = NinjaModel::Relation.new(RelationModel)
    @adapter = mock('Adapter')
    @adapter.stubs(:read).returns(['foo'])
    RelationModel.stubs(:adapter).returns(@adapter)
  }
  subject { @rel }
  it { should respond_to(:to_a) }
  it { should respond_to(:scoping) }
  it { should respond_to(:size) }
  it { should respond_to(:blank?) }
  it { should respond_to(:empty?) }
  it { should respond_to(:order) }
  it { should respond_to(:where) }
  it { should respond_to(:limit) }
  its(:loaded?) { should be_false }
  its(:limit_value) { should be_nil }
  its(:offset_value) { should be_nil }
  its(:ordering) { should be_blank }
  its(:predicates) { should be_blank }
  its(:inspect) { should eql(['foo'].inspect) }

  it 'should respond to array methods' do
    subject.expects(:to_a).returns([])
    subject.flatten
  end

  it 'should respond to scopes' do
    subject.expects(:merge)
    subject.foo
  end

  it 'should raise NoMethodError for a true invalid method' do
    lambda { subject.blarg }.should raise_error(NoMethodError)
  end

  describe 'first' do
    context 'with no arguments' do
      it 'should call find_first' do
        @rel.expects(:find_first)
        @rel.first
      end
    end
    context 'with find arguments' do
      it 'should update the relation and return the first record' do
        @rel.expects(:apply_finder_options).with(:arg1 => 1).returns(@rel)
        @rel.first(:arg1 => 1)
      end
    end
  end

  describe 'all' do
    context 'with no arguments' do
      it 'should call to_a' do
        @rel.expects(:to_a)
        @rel.all
      end
      context 'when chained to a find_first' do
        it 'should reuse the cached records' do
          @rel.all
          @rel.expects(:to_a).never
          @rel.find(:first)
        end
      end
    end

    context 'with arguments' do
      it 'should update the relation and call to_a' do
        @rel.expects(:apply_finder_options).with(:arg1 => 1)
        @rel.all(:arg1 => 1)
      end
    end
  end

  describe 'find' do
    context 'with no args' do
      it 'should raise RecordNotFound' do
        lambda { subject.find }.should raise_error(NinjaModel::RecordNotFound)
      end
    end
    context 'with an id arg' do
      it 'should call find_one' do
        subject.expects(:find_one).with(1)
        subject.find(1)
      end
      it 'add the primary key to the relation' do
        subject.expects(:where).with(:id => 1).returns(subject)
        subject.find(1)
      end
    end
    context 'with :all as the arg' do
      it 'should call :all' do
        subject.expects(:all)
        subject.find(:all)
      end
    end
    context 'with an array of ids' do
      it 'should raise NotImplementedError' do
        lambda { subject.find([1, 2, 3]) }.should raise_error(NotImplementedError)
      end
    end
    context 'with query arguments' do
      it 'should update the relation' do
        subject.expects(:apply_finder_options).with(:arg1 => 2).returns(@rel)
        subject.find(:first, :arg1 => 2)
      end
    end
  end

  describe 'exists?' do
    it 'should add the where predicate for the id' do
      @rel.expects(:where).with(:id => 3).returns(@rel)
      @rel.exists?(3)
    end
  end

  describe 'order' do
    it 'should update the ordering' do
      @rel2 = @rel.order(:attr1 => :desc).order(:attr2 => :asc)
      @rel2.ordering.should eql([{:attr1 => :desc}, {:attr2 => :asc}])
    end
  end

  describe 'where' do
    it 'should merge the predicates' do
      @rel2 = @rel.where(:attr1 => 1).where(:attr2 => 'foo')
      @rel2.predicates.length.should eql(2)
    end
    it 'should accept a hash' do
      @rel2 = @rel.where(:attr1 => 1)
      @pred = @rel2.predicates.first
      @pred.attribute.should eql(:attr1)
      @pred.meth.should eql(:eq)
      @pred.value.should eql(1)
    end
    it 'should accept an array' do
      @rel2 = @rel.where([{:attr1 => 1}, {:attr2 => 'foo'}])
      @pred = @rel2.predicates.first
      @pred.attribute.should eql(:attr1)
      @pred.meth.should eql(:eq)
      @pred.value.should eql(1)
      @pred = @rel2.predicates.last
      @pred.attribute.should eql(:attr2)
      @pred.meth.should eql(:eq)
      @pred.value.should eql('foo')
    end
    it 'should accept a Predicate' do
      @pred = NinjaModel::Predicate.new(:attr1, :ne, 3)
      @rel2 = @rel.where(@pred)
      @rel2.predicates.first.attribute.should eql(:attr1)
      @rel2.predicates.first.meth.should eql(:ne)
      @rel2.predicates.first.value.should eql(3)
    end
    it 'should accept a predicate symbol' do
      @rel2 = @rel.where(:attr1.gt => 2)
      @rel2.predicates.first.attribute.should eql(:attr1)
      @rel2.predicates.first.meth.should eql(:gt)
      @rel2.predicates.first.value.should eql(2)
    end
    it 'should raise an exception for an invalid attribute' do
      lambda { @rel.where(:attr3 => 4) }.should raise_error(ArgumentError)
    end
    it 'should raise an error for an unsupported argument' do
      lambda { @rel.where(1) }.should raise_error(ArgumentError)
    end
    it 'should raise an error for a string' do
      lambda { @rel.where('attr4 = 5') }.should raise_error(ArgumentError)
    end
    it 'should raise an error for an unsupported hash key' do
      lambda { @rel.where(1 => 34) }.should raise_error(ArgumentError)
    end
  end

  describe 'limit' do
    it 'should update the limit value' do
      @rel2 = @rel.limit(5)
      @rel2.limit_value.should eql(5)
      @rel2 = @rel2.limit(10)
      @rel2.limit_value.should eql(10)
    end
  end

  describe 'when triggered' do
    it 'should read from the adapter' do
      @adapter.expects(:read)
      subject.to_a
    end
    it 'should be loaded' do
      subject.to_a
      subject.loaded?.should be_true
    end
    it 'should not access the adapter when triggered a second time' do
      subject.to_a
      @adapter.expects(:read).never
      subject.to_a
    end
    context 'with a valid result' do
      before {
        @records = [mock('Record')]
        @adapter.stubs(:read).returns(@records)
      }
      its(:to_a) { should eql(@records) }
      its(:size) { should eql(1) }
      its(:blank?) { should be_false }
      its(:empty?) { should be_false }
    end
  end
end
