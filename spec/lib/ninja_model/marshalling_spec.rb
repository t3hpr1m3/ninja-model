require 'spec_helper'

describe NinjaModel::Marshalling do
  let(:adapter) { mock('Adapter') }

  class MarshallingModel < NinjaModel::Base
    attribute :attr_string,     :string
    attribute :attr_int,        :integer
    attribute :attr_float,      :float
    attribute :attr_date,       :date
    attribute :attr_datetime,   :datetime
    attribute :attr_bool,       :boolean
  end

  it 'should properly serialize/deserialize' do
    original = MarshallingModel.new
    original.attr_string    = 'teststring'
    original.attr_int       = 777
    original.attr_float     = 3.14
    original.attr_date      = Date.new(1976, 6, 22)
    original.attr_datetime  = DateTime.new(1976, 6, 22, 4, 19, 59)
    original.attr_bool      = true
    serialized = Marshal.dump(original)
    copy = Marshal.load(serialized)
    copy.attr_string.should eql('teststring')
    copy.attr_int.should eql(777)
    copy.attr_float.should eql(3.14)
    copy.attr_date.year.should eql(1976)
    copy.attr_datetime.hour.should eql(4)
    copy.attr_bool.should be_true
  end
end
