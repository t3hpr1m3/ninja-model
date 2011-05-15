require 'spec_helper'

describe NinjaModel::Adapters::AdapterPool do
  class DummyAdapter < NinjaModel::Adapters::AbstractAdapter; end
  before {
    @spec = NinjaModel::Adapters::AdapterSpecification.new({}, :dummy)
    NinjaModel::Base.register_adapter(:dummy, DummyAdapter)
    @pool = NinjaModel::Adapters::AdapterPool.new(@spec)
  }
  subject { @pool }
  its(:spec) { should eql(@spec) }
  its(:instances) { should be_empty }
  its(:connected?) { should be_false }
  its(:current_instance_id) { should eql(Thread.current.object_id) }

  describe 'obtaining an adapter instance' do
    it 'should store the instance for a given thread' do
      subject.instance
      subject.expects(:checkout).never
      subject.instance
    end
  end

  describe 'releasing an adapter instance' do
    it 'should call checkout when obtaining another instance' do
      subject.expects(:checkout).twice
      subject.instance
      subject.release_instance
      subject.instance
    end
  end

  describe 'with_instance' do
    it 'should yield an instance' do
      @inst = nil
      subject.with_instance do |inst|
        @inst = inst
      end
      @inst.should be_kind_of(DummyAdapter)
    end
    it 'should release the instance when complete' do
      subject.expects(:release_instance).with(subject.send :current_instance_id)
      subject.with_instance do |inst|
      end
    end
  end

  describe 'shutdown!' do
    it 'should checkin all assigned instances' do
      @inst = subject.instance
      subject.expects(:checkin).with(@inst)
      subject.shutdown!
    end
    it 'should call disconnect on all instances' do
      @inst = subject.instance
      @inst.expects(:disconnect!)
      subject.shutdown!
    end
  end

  describe 'clear_stale_cached_instances!' do
    it 'should reap any instances for dead threads' do
      @thread = mock('Thread') do
        stubs(:object_id).returns(Thread.current.object_id)
        stubs(:alive?).returns(false)
      end
      Thread.stubs(:list).returns([@thread])
      @inst = subject.instance
      subject.expects(:checkin).with(@inst)
      subject.send :clear_stale_cached_instances!
    end
    it 'should not reap instances for live threads' do
      @thread = mock('Thread') do
        stubs(:object_id).returns(Thread.current.object_id)
        stubs(:alive?).returns(true)
      end
      Thread.stubs(:list).returns([@thread])
      @inst = subject.instance
      subject.expects(:checkin).with(@inst).never
      subject.send :clear_stale_cached_instances!
    end
  end

  describe 'checkout' do
    subject { NinjaModel::Adapters::AdapterPool.new(@spec) }
    context 'with no current instances' do
      it 'should checkout a new instance' do
        subject.expects(:checkout_new_instance).returns('foo')
        subject.send(:checkout)
      end
      it 'should store the instance' do
        subject.send(:checkout)
        subject.instances.count.should eql(1)
      end
    end

    context 'with 1 existing instance' do
      context 'that is already assigned' do
        it 'should checkout a new instance' do
          threads = []
          subject.expects(:new_instance).twice.returns(NinjaModel::Adapters::AdapterManager.registered[subject.spec.name].new(subject.spec.config))
          2.times do |idx|
            threads << Thread.new do
              subject.send(:checkout)
            end
          end
          threads.each { |t| t.join }
        end
      end
      context 'that is not assigned' do
        it 'should checkout the existing instance' do
          subject.expects(:checkout_existing_instance).returns('existing')
          subject.instance
          subject.release_instance
          subject.instances.count.should eql(1)
          subject.send(:checkout)
        end
      end
    end

    context 'with the maximum number of instances' do
      context 'with an available instance' do
        it 'should successfully check out an instance' do
          subject.instance
          threads = []
          4.times do |idx|
            threads << Thread.new do
              subject.instance
            end
          end
          threads.each { |t| t.join }
          subject.release_instance
          subject.send(:checkout).should_not be_nil
        end
      end

      context 'with no available instances' do
        it 'should raise a ConnectionTimeoutError' do
          threads = []
          5.times do |idx|
            threads << Thread.new do
              subject.instance
            end
          end
          threads.each { |t| t.join }
          subject.stubs(:clear_stale_cached_instances!)
          lambda { subject.instance }.should raise_error(NinjaModel::ConnectionTimeoutError)
        end
      end

      context 'with instances that can be reaped' do
        it 'should return an existing instance' do
          threads = []
          5.times do |idx|
            threads << Thread.new do
              subject.instance
            end
          end
          threads.each { |t| t.join }
          subject.expects(:checkout_existing_instance).returns('foo')
          subject.instance
        end
      end
    end

  end
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
end
