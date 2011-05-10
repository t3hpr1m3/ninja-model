require 'spec_helper'

#describe NinjaModel::Attributes do
#  before(:each) do
#    @klass = Class.new do
#      def initialize
#        @attributes = {}.with_indifferent_access
#      end
#    end
#    @klass.send :include, NinjaModel::Attributes
#    @klass.send :attr_reader, :attributes
#  end
#
#  describe 'adding an attribute' do
#    before(:each) do
#      @klass.attribute :var, :string
#      @obj = @klass.new
#    end
#
#    it 'should add a new attribute' do
#      @klass.model_attributes[:var].type.should eql(:string)
#    end
#
#    it 'should add a read method' do
#      lambda { @obj.send :var }.should_not raise_error(NoMethodError)
#    end
#
#    it 'should add a write method' do
#      lambda { @obj.send :var= }.should_not raise_error(NoMethodError)
#    end
#  end
#
#  describe 'with an instance' do
#    describe 'writing an attribute value' do
#      before(:each) do
#        @klass.attribute :valid, :string
#        @obj = @klass.new
#      end
#
#      it 'should raise an error when writing an invalid attribute' do
#        lambda { @obj.write_attribute(:invalid, 'test') }.should raise_error(NoMethodError)
#      end
#
#      it 'should properly update a valid attribute' do
#        @obj.write_attribute(:valid, 'test')
#        @obj.attributes['valid'].should eql('test')
#      end
#    end
#
#    describe 'assigning from a hash' do
#      before(:each) do
#        @klass.attribute :valid, :string
#        @obj = @klass.new
#      end
#
#      it 'should update instance attributes' do
#        attrs = {:valid => 'valid value'}
#        @obj.send :attributes=, attrs
#        @obj.valid.should eql('valid value')
#      end
#    end
#
#    describe 'checking existence of an attribute' do
#      before(:each) do
#        @klass.attribute :valid, :string
#        @obj = @klass.new
#      end
#      it { (@obj.send :attribute_method?, :valid).should be_true }
#      it { (@obj.send :attribute_method?, 'valid').should be_true }
#      it { (@obj.send :attribute_method?, :invalid).should be_false }
#    end
#
#    describe 'assigining default attributes from model' do
#      before(:each) do
#        @klass.attribute :valid, :string, {:default => 'foobar'}
#        @klass.send :class_inheritable_accessor, :primary_key
#        @obj = @klass.new
#        @attrs = @obj.attributes_from_model_attributes
#      end
#      it { @attrs.should have_key('valid') }
#      it { @attrs[:valid].should eql('foobar') }
#    end
#  end
#end
