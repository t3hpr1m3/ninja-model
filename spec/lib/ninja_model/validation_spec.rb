require 'spec_helper'

describe NinjaModel::Validation do
  class ValidationModel < NinjaModel::Base
    attribute :testing, :integer
    validates :testing, :numericality => true
  end

  before {
    @obj = ValidationModel.new
  }
  subject { @obj }
  it { should respond_to(:save) }
  it { should respond_to(:valid?) }

  describe 'save' do
    it 'should run the validation callbacks' do
      subject.expects(:run_callbacks).with(:validation).yields
      subject.expects(:run_callbacks).with(:validate)
      subject.save
    end
  end
end
