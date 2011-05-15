require 'spec_helper'

describe NinjaModel::Persistence do
  class PersistenceModel < NinjaModel::Base
    attribute :testing, :integer
  end

  before {
    @obj = PersistenceModel.new
    @adapter = mock('Adapter')
    @obj.class.stubs(:adapter).returns(@adapter)
  }
  subject { @obj }
  it { should respond_to(:save) }
  it { should respond_to(:create) }
  it { should respond_to(:update) }
  it { should respond_to(:new_record?) }
  it { should respond_to(:destroyed?) }
  it { should respond_to(:persisted?) }
  it { should respond_to(:destroy) }
  it { should respond_to(:reload) }
  it { should respond_to(:update_attributes) }
  its(:new_record?) { should be_true }
  its(:persisted?) { should be_false }
  its(:destroyed?) { should be_false }

  describe 'save' do
    before { subject.stubs(:run_callbacks).yields(true) }
    it 'should run the save callbacks' do
      subject.expects(:run_callbacks).with(:save)
      subject.save
    end

    it 'should call create for a new record' do
      subject.stubs(:new_record?).returns(true)
      subject.expects(:create)
      subject.save
    end

    it 'should call update for a persisted record' do
      subject.stubs(:new_record?).returns(false)
      subject.expects(:update)
      subject.save
    end

    it 'should clear the changed attributes after successful save' do
      attributes = {}
      subject.stubs(:changed_attributes).returns(attributes)
      subject.stubs(:new_record?).returns(false)
      subject.stubs(:update).returns(true)
      attributes.expects(:clear)
      subject.save
    end

    it 'should not clear the changed attributes after unsuccessful save' do
      attributes = {}
      subject.stubs(:changed_attributes).returns(attributes)
      subject.stubs(:new_record?).returns(false)
      subject.stubs(:update).returns(false)
      attributes.expects(:clear).never
      subject.save
    end
  end

  describe 'create' do
    before {
      subject.stubs(:run_callbacks).yields(true)
      @adapter.stubs(:create).returns(true)
    }
    it 'should run the create callbacks' do
      subject.expects(:run_callbacks).with(:create)
      subject.create
    end
    it 'should call create on the adapter' do
      @adapter.expects(:create).with(subject)
      subject.create
    end
    it 'should update the persisted status' do
      subject.create
      subject.persisted?.should be_true
    end
  end

  describe 'update' do
    before {
      subject.stubs(:run_callbacks).yields(true)
      @adapter.stubs(:update).returns(true)
    }
    it 'should run the update callbacks' do
      subject.expects(:run_callbacks).with(:update)
      subject.update
    end
    it 'should call update on the adapter' do
      @adapter.expects(:update).with(subject)
      subject.update
    end
  end

  describe 'destroy' do
    before {
      @adapter.stubs(:destroy).returns(true)
    }
    it 'should run the destroy callbacks' do
      subject.expects(:run_callbacks).with(:destroy)
      subject.destroy
    end
    it 'should call destroy on the adapter' do
      @adapter.expects(:destroy).with(subject)
      subject.destroy
    end
    it 'should update the destroyed? status' do
      subject.destroy
      subject.destroyed?.should be_true
    end
    it 'should not be persisted afterwards' do
      subject.destroy
      subject.persisted?.should be_false
    end
  end

  describe 'reload' do
    it 'should call reload on the adapter' do
      @adapter.expects(:reload).with(subject)
      subject.reload
    end
  end

  describe 'update_attributes' do
    it 'update the attributes hash and save' do
      subject.expects(:save)
      subject.update_attributes(:testing => 2)
      subject.testing.should eql(2)
    end
  end
end
