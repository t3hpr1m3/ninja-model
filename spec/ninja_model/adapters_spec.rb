require 'spec_helper'

describe NinjaModel::Adapters do
  class DummyAdapter < NinjaModel::Adapters::AbstractAdapter; end
  class SmarterAdapter < NinjaModel::Adapters::AbstractAdapter; end
  before {
    NinjaModel::Base.register_adapter(:dummy, DummyAdapter)
    NinjaModel::Base.register_adapter(:smarter, SmarterAdapter)
  }
  subject { Class.new(NinjaModel::Base) }
  it { should respond_to(:register_adapter) }
  it { should respond_to(:set_adapter) }

  describe 'adapter' do
    before { @klass = Class.new(NinjaModel::Base) }
    subject { @klass.new }
    it 'should call retrieve_adapter' do
      @klass.expects(:retrieve_adapter)
      subject.adapter
    end
  end

  describe 'register_adapter' do
    it 'should register with the adapter manager' do
      subject.adapter_manager.class.expects(:register_adapter_class).with(:dummy, DummyAdapter)
      subject.register_adapter(:dummy, DummyAdapter)
    end
  end

  describe 'set_adapter' do
    before {
      @configuration = mock('Configuration') do
        stubs(:specs).returns({'development' => {:adapter => :dummy}})
      end
      NinjaModel.stubs(:configuration).returns(@configuration)
      @klass = Class.new(NinjaModel::Base)
    }
    subject { @klass }
    it 'should return a DummyAdapter pool when nil is passed' do
      subject.set_adapter.spec.name.should eql(:dummy)
    end
    it 'should return a DummyAdapter pool when "development" is passed' do
      subject.set_adapter('development').spec.name.should eql(:dummy)
    end
    it 'should return a DummyAdapter pool when a dummy specification is passed' do
      subject.set_adapter(:adapter => :dummy).spec.name.should eql(:dummy)
    end
    it 'should return a SmarterAdapter pool when a smarter specification is passed' do
      subject.set_adapter(:adapter => :smarter).spec.name.should eql(:smarter)
    end
    it 'should raise AdapterNotSpecified if the configuration doesn\'t specify an adapter' do
      lambda { subject.set_adapter({}) }.should raise_error(NinjaModel::Adapters::AdapterNotSpecified)
    end
    it 'should raise InvalidAdapter for an invalid adapter name' do
      lambda { subject.set_adapter(:adapter => :bogus) }.should raise_error(NinjaModel::Adapters::InvalidAdapter)
    end
    it 'should raise InvalidSpecification for an invalid Rails.env' do
      lambda { subject.set_adapter('foobar') }.should raise_error(NinjaModel::Adapters::InvalidSpecification)
    end
  end

  describe 'retrieve_adapter' do
    before { @klass = Class.new(NinjaModel::Base) }
    it 'should call retrieve_adapter on the manager' do
      @klass.adapter_manager.expects(:retrieve_adapter).with(@klass)
      @klass.retrieve_adapter
    end
  end

  describe 'shutdown_adapter' do
    before { @klass = Class.new(NinjaModel::Base) }
    it 'should call remove_adapter on the manager' do
      @klass.adapter_manager.expects(:remove_adapter).with(@klass)
      @klass.shutdown_adapter
    end
  end
end
