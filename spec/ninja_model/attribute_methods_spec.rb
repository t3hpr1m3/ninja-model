require 'spec_helper'

describe NinjaModel::AttributeMethods do
  class AttributeModel < NinjaModel::Base
    attribute :test, :string
  end
  subject { AttributeModel.new }
  specify { subject.send(:attribute_method?, 'test').should be_true }
  specify { subject.send(:attribute_method?, 'invalid').should be_false }

  it 'should return a list of valid attribute names' do
    AttributeModel.attribute_names.should eql(['test'])
  end

  it 'should return a valid column list' do
    AttributeModel.columns.length.should eql(1)
  end

  it 'should allow updating by hash' do
    subject.attributes = {:test => 'hashvalue'}
    subject.test.should eql('hashvalue')
  end
end

describe NinjaModel::AttributeMethods, 'reading an attribute' do
  class ReaderModel < NinjaModel::Base
    attribute :test, :string
  end
  subject { ReaderModel.new }
  it { should respond_to(:test) }
  it 'should call "read_attribute"' do
    subject.expects(:read_attribute).with('test')
    subject.test
  end

  context 'by hash key' do
    it 'should call "read_attribute"' do
      subject.expects(:read_attribute).with(:test)
      subject[:test]
    end
    it 'should return the correct value' do
      subject.test = 'hashcorrect'
      subject[:test].should eql('hashcorrect')
    end
    it 'should accept a string hash key' do
      subject.test = 'stringkey'
      subject['test'].should eql('stringkey')
    end
  end

  context 'before_type_cast' do
    it 'should not convert the value' do
      subject.test = Date.new(2001,1,1)
      subject.test_before_type_cast.should eql(Date.new(2001,1,1))
    end
  end
end

describe NinjaModel::AttributeMethods, 'writing an attribute' do
  class WriterModel < NinjaModel::Base
    attribute :test, :string
  end
  subject { WriterModel.new }
  it 'should call "write_attribute"' do
    subject.expects(:write_attribute).with('test', 'newvalue')
    subject.test = 'newvalue'
  end
  it 'should update the value' do
    subject.test = 'newvalue'
    subject.test.should eql('newvalue')
  end
  it 'should be dirty' do
    subject.test = 'newvalue'
    subject.changed?.should be_true
    subject.test_changed?.should be_true
  end
  it 'should raise an exception for an invalid attribute name' do
    lambda { subject.write_attribute(:invalid, 'foo') }.should raise_error(NoMethodError)
  end

  context 'by hash key' do
    it 'should call "write_attribute"' do
      subject.expects(:write_attribute).with(:test, 'newvalue')
      subject[:test] = 'newvalue'
    end
    it 'should update the value' do
      subject[:test] = 'newvalue'
      subject.test.should eql('newvalue')
    end
    it 'should accept a string hash key' do
      subject['test'] = 'stringkey'
      subject.test.should eql('stringkey')
    end
  end
end
