require 'spec_helper'

#describe NinjaModel::Identity do
#  before(:each) do
#    @klass = Class.new
#    @klass.send :include, NinjaModel::Identity
#  end
#
#  def persisted
#    obj = @klass.new
#    obj.stubs(:id).returns(123)
#    obj.stubs(:persisted?).returns(true)
#    obj
#  end
#
#  def unpersisted
#    obj = @klass.new
#    obj.stubs(:persisted?).returns(false)
#    obj
#  end
#
#  describe 'to_key' do
#    it 'should generate a key when persisted' do
#      persisted.to_key.should eql([123])
#    end
#
#    it 'should return nil when not persisted' do
#      unpersisted.to_key.should be_nil
#    end
#  end
#
#  describe 'to_param' do
#    it 'should generate a param when persisted' do
#      persisted.to_param.should eql('123')
#    end
#
#    it 'should return nil when not persisted' do
#      unpersisted.to_param.should be_nil
#    end
#  end
#end
