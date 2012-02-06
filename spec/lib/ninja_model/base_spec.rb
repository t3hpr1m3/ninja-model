require 'spec_helper'

describe NinjaModel::Base do
  class LintTester < NinjaModel::Base; end
  subject { LintTester.new }
  it_should_behave_like "ActiveModel"
  before {
    @klass = Class.new(NinjaModel::Base)
    @klass.send :attribute, :width, :integer
    @klass.send :attribute, :height, :integer
    @klass.send :attribute, :color, :string
  }

  it 'should instantiate from an existing data structure' do
    attrs = {:width => 100, :height => 200, :color => 'red'}
    @obj = @klass.new
    @obj.instantiate(attrs)
    @obj.width.should eql(100)
  end
end
