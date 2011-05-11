require 'spec_helper'

describe NinjaModel::Identity do
  class IdentityModel < NinjaModel::Base
    attribute :primary, :integer, :primary_key => true
  end
  before {
    @obj = IdentityModel.new
    @obj.primary = 123
    @obj
  }
  subject { @obj }

  context 'when persisted' do
    before { @obj.stubs(:persisted?).returns(true) }
    its(:to_param) { should eql('123') }
    its(:to_key) { should eql([123]) }
  end

  context 'when not persisted' do
    before { @obj.stubs(:persisted?).returns(false) }
    its(:to_param) { should be_nil }
    its(:to_key) { should be_nil }
  end
end
