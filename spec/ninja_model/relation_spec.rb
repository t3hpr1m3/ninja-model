require 'spec_helper'

describe NinjaModel::Relation do
  describe 'with an instance' do
    before(:each) do
      @model = mock('NinjaModel')
      @model.stubs(:adapter => stub('NinjaAdapter', :read => 'object_list'))
      @rel = NinjaModel::Relation.new(@model)
    end
    it { @rel.should respond_to(:klass) }
    it { @rel.should respond_to(:loaded?) }
    it { @rel.should respond_to(:limit_value) }
    it { @rel.limit_value.should be_nil }
    it { @rel.should respond_to(:offset_value) }
    it { @rel.offset_value.should be_nil }
    it { @rel.should respond_to(:ordering) }
    it { @rel.ordering.should eql([]) }
    it { @rel.should respond_to(:predicates) }
    it { @rel.predicates.should eql([]) }
    it { @rel.loaded?.should be_false }

    it 'should try to read when to_a is called' do
      @rel.to_a.should eql('object_list')
    end
  end
end
