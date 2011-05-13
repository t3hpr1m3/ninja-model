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

  describe 'test' do
    context 'with a @value of 1' do
      NinjaModel::Predicate::PREDICATES.each do |p|
        if p.eql?(:in)
          subject { NinjaModel::Predicate.new(:var, :in, 1) }
          describe ':in 2' do
            specify { lambda { subject.test(2) }.should raise_error }
          end
        else
          before {
            @pred = NinjaModel::Predicate.new(:var, p, 1)
            @test_value = 2
            @expectations = {
              :eq => false,
              :ne => true,
              :gt => true,
              :gte => false,
              :lt => false,
              :lte => false
            }
          }
          subject { @pred }
          describe "#{subject.instance_variable_get(:@method)} #{@test_value}" do
            specify { subject.test(@test_value).should eql(@expectations[p]) }
          end
        end
      end
    end
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
