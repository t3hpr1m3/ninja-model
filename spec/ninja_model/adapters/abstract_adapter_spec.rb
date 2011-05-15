require 'spec_helper'

describe NinjaModel::Adapters::AbstractAdapter do
  subject { NinjaModel::Adapters::AbstractAdapter.new({}) }
  it { should respond_to(:reconnect!) }
  it { should respond_to(:disconnect!) }
  it { should respond_to(:reset!) }
  it { should respond_to(:verify!) }
  it { should respond_to(:create) }
  it { should respond_to(:read) }
  it { should respond_to(:update) }
  it { should respond_to(:destroy) }
  its(:adapter_name) { should eql('Abstract') }
  its(:persistent_connection?) { should be_true }
  its(:active?) { should be_false }
  specify { subject.create({}).should be_false }
  specify { subject.read({}).should be_nil }
  specify { subject.update({}).should be_false }
  specify { subject.destroy({}).should be_false }

  it 'should be active after reconnect' do
    subject.reconnect!
    subject.active?.should be_true
  end

  describe 'verify!' do
    it 'should call reconnect! when inactive' do
      subject.stubs(:active?).returns(false)
      subject.expects(:reconnect!)
      subject.verify!
    end

    it 'should not call reconnect! when active' do
      subject.stubs(:active?).returns(true)
      subject.expects(:reconnect!).never
      subject.verify!
    end
  end

  it 'should be inactive after disconnect' do
    subject.reconnect!
    subject.disconnect!
    subject.active?.should be_false
  end
end
