require 'spec_helper'
require 'ninja_model'

#describe NinjaModel::Adapters::AdapterPool do
#  before(:each) do
#    @spec = mock('AdapterSpecification') do
#      stubs(:adapter_method).returns(:dummy_adapter)
#      stubs(:config)
#    end
#
#    @adapter = mock('AbstractAdapter') do
#      stubs(:verify!)
#    end
#
#    @pool = NinjaModel::Adapters::AdapterPool.new(@spec)
#    @thread = mock('thread') do
#      stubs('object_id').returns(123)
#    end
#    Thread.stubs(:current).returns(@thread)
#    NinjaModel::Base.stubs(:dummy_adapter).returns(@adapter)
#  end
#
#  it 'should properly respond to connected?' do
#    @pool.connected?.should be_false
#    @pool.instance
#    @pool.connected?.should be_true
#  end
#
#  it 'should initialize from an AdapterSpecification' do
#    spec = mock('AdapterSpecification')
#    NinjaModel::Adapters::AdapterPool.new(spec).spec.should eql(spec)
#  end
#
#  it 'should return a valid instance_id' do
#    (@pool.send :current_instance_id).should eql(@thread.object_id)
#  end
#
#  describe 'when creating an instance' do
#    it 'should create a valid instance' do
#      (@pool.send :new_instance).should eql(@adapter)
#    end
#
#    it 'should store the instance' do
#      @pool.stubs(:new_instance).returns(@adapter)
#      @pool.instance
#      @pool.instances.should include(@adapter)
#    end
#
#    it 'should assign the instance to the current_thread' do
#      @pool.stubs(:new_instance).returns(@adapter)
#      @pool.instance
#      @pool.stubs(:checkout).returns("new_instance")
#      @pool.instance.should_not eql("new_instance")
#      @pool.instance.should eql(@adapter)
#    end
#
#    it 'should reuse an unallocated instance' do
#      @pool.stubs(:current_instance_id).returns(123)
#      inst = @pool.instance
#      @pool.release_instance(123)
#      @pool.instance.should eql(inst)
#    end
#  end
#
#  it 'should properly allocate/deallocate instances' do
#    @pool.stubs(:current_instance_id).returns(123)
#    @pool.expects(:checkout).returns(@adapter)
#    @pool.expects(:checkin)
#    @pool.with_instance do |instance|
#    end
#  end
#end
