require 'spec_helper'

describe NinjaModel::Predicate do
  before { @pred = NinjaModel::Predicate.new(:var, :ge) }
  subject { @pred }
  it { should respond_to(:value=) }
  its(:has_value?) { should be_false }
  its(:attribute) { should eql(:var) }
  its(:method) { should eql(:ge) }

  it 'should have a value after update' do
    subject.value = 'valued'
    subject.has_value?.should be_true
  end
end

#describe NinjaModel::Predicate do
#  before(:each) do
#    @pred = NinjaModel::Predicate.new(:var, :ge)
#  end
#
#  it { @pred.has_value?.should be_false }
#  it 'should have value after update' do
#    @pred.value = 'value'
#    @pred.has_value?.should be_true
#  end
#end
