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
    before do
      subject.stubs(create: true)
    end
    it 'should run the validation callbacks' do
      subject.expects(:run_callbacks).with(:validation).yields
      subject.expects(:run_callbacks).with(:validate)
      subject.save
    end

    it 'should skip validation if validate is false' do
      #subject.stubs(:run_callbacks).yields
      subject.expects(:valid?).never
      subject.save(validate: false)
    end
  end
end
