require 'spec_helper'

describe NinjaModel::Persistence do
  let(:adapter) { mock('Adapter') }
  class PersistenceModel < NinjaModel::Base
    attribute :testing, :integer
  end

  before {
    @obj = PersistenceModel.new
    @obj.class.stubs(adapter: adapter)
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
    it 'should call create for a new record' do
      subject.stubs(new_record?: true)
      subject.expects(:create)
      subject.save
    end

    it 'should call update for a persisted record' do
      subject.stubs(new_record?: false)
      subject.expects(:update)
      subject.save
    end

    it 'should clear the changed attributes after successful save' do
      attributes = {}
      subject.stubs(changed_attributes: attributes, new_record?: false, update: true)
      attributes.expects(:clear)
      subject.save
    end

    it 'should not clear the changed attributes after unsuccessful save' do
      attributes = {}
      subject.stubs(changed_attributes: attributes, new_record?: false, update: false)
      attributes.expects(:clear).never
      subject.save
    end
  end

  describe 'create' do
    it 'should call create on the adapter' do
      adapter.expects(:create).with(subject)
      subject.create
    end
    it 'should update the persisted status' do
      adapter.stubs(create: true)
      subject.create
      subject.persisted?.should be_true
    end
  end

  describe 'update' do
    it 'should call update on the adapter' do
      adapter.expects(:update).with(subject)
      subject.update
    end
  end

  describe 'destroy' do
    it 'should call destroy on the adapter' do
      adapter.expects(:destroy).with(subject)
      subject.destroy
    end
    it 'should update the destroyed? status' do
      adapter.stubs(destroy: true)
      subject.destroy
      subject.destroyed?.should be_true
    end
    it 'should not be persisted afterwards' do
      adapter.stubs(destroy: true)
      subject.destroy
      subject.persisted?.should be_false
    end
  end

  describe 'reload' do
    it 'should call reload on the adapter' do
      adapter.expects(:reload).with(subject)
      subject.reload
    end
  end

  describe 'update_attributes' do
    it 'update the attributes hash and save' do
      subject.expects(:save)
      subject.update_attributes(testing: 2)
      subject.testing.should eql(2)
    end
  end
end
