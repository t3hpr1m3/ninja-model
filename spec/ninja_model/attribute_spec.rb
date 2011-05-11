require 'spec_helper'

describe NinjaModel::Attribute do
  def mock_attribute(*args)
    NinjaModel::Attribute.new(*args)
  end

  RSpec::Matchers.define :convert do |input|
    chain :to do |expected|
      @expected = expected
    end

    match do |attr|
      @actual = attr.convert(input)
      @actual.eql?(@expected)
    end

    failure_message_for_should do |attr|
      "convert(#{input.inspect}) should be #{@expected.inspect}, but got #{@actual.inspect}"
    end

    description do |attr|
      "convert #{input.inspect} to #{@expected.inspect}"
    end
  end

  context 'an instance' do
    before {
      @date_obj = Date.new(2001,1,1)
      @datetime_obj = DateTime.new(2001,1,1)
    }
    subject { mock_attribute(:foo, :string, :default => 'bar') }
    it { should respond_to(:name) }
    it { should respond_to(:type) }
    it { should respond_to(:default) }
    its(:name) { should eql('foo') }
    its(:type) { should eql(:string) }
    its(:default) { should eql('bar') }

    context 'with a :string type' do
      subject { mock_attribute(:test, :string) }
      it { should convert('').to('') }
      it { should convert('foo').to('foo') }
      it { should convert(123).to('123') }
      it { should convert(1.23).to('1.23') }
      it { should convert(@date_obj).to(@date_obj.to_s) }
      it { should convert(@datetime_obj).to(@datetime_obj.to_s) }
      it { should convert(true).to('true') }
      it { should convert(false).to('false') }
      it { should convert(nil).to(nil) }
      it 'should raise an error with an unconvertable value' do
        lambda { subject.convert([]) }.should raise_error(NinjaModel::InvalidConversion)
      end
      its(:number?) { should be_false }
    end

    context 'with an :integer type' do
      subject { mock_attribute(:test, :integer) }
      it { should convert('').to(0) }
      it { should convert('foo').to(0) }
      it { should convert(123).to(123) }
      it { should convert(1.23).to(1) }
      it { should convert(@date_obj).to(1) }
      it { should convert(@datetime_obj).to(@datetime_obj.to_i) }
      it { should convert(true).to(1) }
      it { should convert(false).to(0) }
      it { should convert(nil).to(0) }
      its(:number?) { should be_true }
    end

    context 'with a :float type' do
      subject { mock_attribute(:test, :float) }
      it { should convert('').to(0.0) }
      it { should convert('foo').to(0.0) }
      it { should convert(123).to(123.0) }
      it { should convert(1.23).to(1.23) }
      it { should convert(@date_obj).to(1.0) }
      it { should convert(@datetime_obj).to(@datetime_obj.to_f) }
      it { should convert(true).to(1.0) }
      it { should convert(false).to(0.0) }
      it { should convert(nil).to(0.0) }
      its(:number?) { should be_true }
    end

    context 'with a :date type' do
      subject { mock_attribute(:test, :date) }
      it { should convert('').to(nil) }
      it { should convert('foo').to(nil) }
      it { should convert(123).to(123) }
      it { should convert(1.23).to(1.23) }
      it { should convert(@date_obj).to(@date_obj) }
      it { should convert(@datetime_obj).to(@datetime_obj) }
      it { should convert('2001-01-01').to(Date.new(2001,1,1)) }
      it { should convert(true).to(true) }
      it { should convert(false).to(false) }
      it { should convert(nil).to(nil) }
      its(:number?) { should be_false }
    end

    context 'with a :datetime type' do
      subject { mock_attribute(:test, :datetime) }
      it { should convert('').to(nil) }
      it { should convert('foo').to(nil) }
      it { should convert(123).to(123) }
      it { should convert(1.23).to(1.23) }
      it { should convert(@date_obj).to(@date_obj) }
      it { should convert(@datetime_obj).to(@datetime_obj) }
      it { should convert('2001-01-01 01:01:00').to(DateTime.new(2001,1,1,1,1)) }
      it { should convert(true).to(true) }
      it { should convert(false).to(false) }
      it { should convert(nil).to(nil) }
      its(:number?) { should be_false }
    end

    context 'with a :boolean type' do
      subject { mock_attribute(:test, :boolean) }
      it { should convert('').to(nil) }
      it { should convert('foo').to(false) }
      it { should convert(123).to(false) }
      it { should convert(1.23).to(false) }
      it { should convert(@date_obj).to(false) }
      it { should convert(@datetime_obj).to(false) }
      it { should convert(true).to(true) }
      it { should convert(false).to(false) }
      it { should convert(nil).to(false) }
      its(:number?) { should be_false }
    end
  end
end
