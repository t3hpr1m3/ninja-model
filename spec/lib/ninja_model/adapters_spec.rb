require 'spec_helper'

describe NinjaModel::Adapters do
  let(:klass) { Class.new(NinjaModel::Base) }
  #class SmarterAdapter < NinjaModel::Adapters::AbstractAdapter; end
  #before {
  #  NinjaModel::Base.register_adapter(:dummy, DummyAdapter::Adapter)
  #  NinjaModel::Base.register_adapter(:smarter, SmarterAdapter)
  #}
  subject { klass }
  it { should respond_to(:register_adapter) }
  it { should respond_to(:set_adapter) }

  describe 'adapter' do
    subject { klass.new }
    it 'should call retrieve_adapter' do
      klass.expects(:retrieve_adapter)
      subject.adapter
    end
  end

  describe 'register_adapter' do
    context 'with an invalid adapter' do
      it 'should raise an InvalidAdapter exception' do
        lambda { subject.register_adapter(:dummy, Class.new) }.should raise_error(NinjaModel::InvalidAdapter)
      end
    end

    context 'with a valid adapter' do
      let(:adapter) { Class.new(NinjaModel::Adapters::AbstractAdapter) }
      it 'should register with the adapter manager' do
        subject.adapter_manager.class.expects(:register_adapter_class).with(:dummy, adapter)
        subject.register_adapter(:dummy, adapter)
      end
    end
  end

  describe 'set_adapter' do
    let(:spec) { {'development' => {:adapter => :dummy } } }
    let(:configuration) { stub(:specs => spec) }
    let!(:adapter_spec) { NinjaModel::Adapters::AdapterSpecification.new(spec['development'], :dummy) }
    before {
      NinjaModel.stubs(:configuration).returns(configuration)
      NinjaModel::Adapters::AdapterManager.stubs(:registered?).with(:dummy).returns(true)
      NinjaModel::Adapters::AdapterSpecification.stubs(:new).with(spec['development'], :dummy).returns(adapter_spec)
    }
    subject { klass }
    context 'when nil is passed' do
      context 'when rails is unavailable' do
        it 'should raise AdapterNotSpecified' do
          lambda { subject.set_adapter }.should raise_error(NinjaModel::AdapterNotSpecified)
        end
        context 'when Rails is available' do
          it 'should recurse with the Rails environment' do
            rails = Object.const_set('Rails', Class.new(Object))
            rails.stubs(:env).returns('development')
            subject.adapter_manager.expects(:create_adapter).with(subject.name, adapter_spec)
            subject.set_adapter
            Object.send(:remove_const, :Rails)
          end
        end
      end
    end

    context 'when a string is passed' do
      it 'should successfully set an adapter' do
        subject.adapter_manager.expects(:create_adapter).with(subject.name, adapter_spec)
        subject.set_adapter('development')
      end

      context 'and the string is invalid' do
        it 'should raise InvalidSpecification' do
          lambda { subject.set_adapter('foobar') }.should raise_error(NinjaModel::InvalidSpecification)
        end
      end
    end

    context 'when a symbol is passed' do
      it 'should successfully set an adapter' do
        subject.adapter_manager.expects(:create_adapter).with(subject.name, adapter_spec)
        subject.set_adapter(:development)
      end

      context 'and the symbol is invalid' do
        it 'should raise InvalidSpecification' do
          lambda { subject.set_adapter(:foobar) }.should raise_error(NinjaModel::InvalidSpecification)
        end
      end
    end

    context 'when a spec is passed' do
      it 'should successfully set an adapter' do
        subject.adapter_manager.expects(:create_adapter).with(subject.name, adapter_spec)
        subject.set_adapter(spec['development'])

      end
    end

    context 'when a specification is passed' do
      it 'should successfully set an adapter' do
        subject.adapter_manager.expects(:create_adapter).with(subject.name, adapter_spec)
        subject.set_adapter(adapter_spec)
      end
    end
  end

  describe 'retrieve_adapter' do
    it 'should call retrieve_adapter on the manager' do
      klass.adapter_manager.expects(:retrieve_adapter).with(klass)
      klass.retrieve_adapter
    end
  end

  describe 'shutdown_adapter' do
    it 'should call remove_adapter on the manager' do
      klass.adapter_manager.expects(:remove_adapter).with(klass)
      klass.shutdown_adapter
    end
  end
end
