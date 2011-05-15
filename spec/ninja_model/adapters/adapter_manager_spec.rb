require 'spec_helper'

describe NinjaModel::Adapters::AdapterManager do
  class DummyAdapter < NinjaModel::Adapters::AbstractAdapter; end
  class TestModel < NinjaModel::Base; end
  class ChildModel < TestModel; end

  before {
    @manager = NinjaModel::Adapters::AdapterManager.new
    @manager.class.register_adapter_class(:dummy, DummyAdapter)
  }
  subject { @manager }

  it 'should remember registered adapters' do
    subject.class.registered?(:dummy).should be_true
  end

  describe 'creating an adapter' do
    before { @manager.create_adapter('TestModel', NinjaModel::Adapters::AdapterSpecification.new({}, :dummy)) }
    it 'should add the adapter to the pool' do
      @manager.retrieve_adapter_pool(TestModel).spec.name.should eql(:dummy)
    end
    it 'should return the adapter for descendent classes' do
      @manager.retrieve_adapter_pool(ChildModel).spec.name.should eql(:dummy)
    end
  end

  describe 'removing an adapter' do
    before {
      @spec = NinjaModel::Adapters::AdapterSpecification.new({:foo => 'bar'}, :dummy)
      @manager.create_adapter('TestModel', @spec)
    }
    it 'should remove the adapter from the pool' do
      @manager.remove_adapter(TestModel)
      @manager.retrieve_adapter_pool(TestModel).should be_nil
    end
    it 'should cause retrieve_adapter to raise an error' do
      @manager.remove_adapter(TestModel)
      lambda { @manager.retrieve_adapter(TestModel) }.should raise_error(StandardError)
    end
    it 'should return the spec that created it' do
      @manager.remove_adapter(TestModel).should eql({:foo => 'bar'})
    end
  end

  describe 'release_active_adapters!' do
    before {
      @spec = NinjaModel::Adapters::AdapterSpecification.new({:foo => 'bar'}, :dummy)
      @manager.create_adapter('TestModel', @spec)
    }
    it 'should call release_instance on all pools' do
      @pool = @manager.adapter_pools['TestModel']
      @pool.expects(:release_instance)
      @manager.release_active_adapters!
    end
  end

  describe 'release_all_adapters!' do
    before {
      @spec = NinjaModel::Adapters::AdapterSpecification.new({:foo => 'bar'}, :dummy)
      @manager.create_adapter('TestModel', @spec)
    }
    it 'should call shutdown! on all pools' do
      @pool = @manager.adapter_pools['TestModel']
      @pool.expects(:shutdown!)
      @manager.release_all_adapters!
    end
  end
end
