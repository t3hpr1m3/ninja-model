require 'spec_helper'

describe NinjaModel::Scoping do
  before(:each) do
    @klass = Class.new
    @klass.send :include, NinjaModel::Scoping
    @relation = mock('Relation') do
      stubs(:apply_finder_options).returns(self)
    end
    @klass.stubs(:relation).returns(@relation)
    @klass.stubs(:current_scoped_methods).returns(nil)
  end

  describe 'scoped' do
    it 'should return a relation when no options are sent' do
      @klass.scoped.should be_instance_of(@relation.class)
    end

    it 'should accept scoping options' do
      @klass.scoped(:conditions => {:key => 'value'}).should be_instance_of(@relation.class)

    end
  end

  describe 'scopes' do
    it 'should return an empty hash when no scopes have been set' do
      @klass.scopes.should eql({})
    end

    it 'should return existing scopes' do
      scopes = mock('scopes')
      @klass.stubs(:read_inheritable_attribute).returns(scopes)
      @klass.scopes.should eql(scopes)
    end
  end

  describe 'defining a scope' do
    
  end
end
