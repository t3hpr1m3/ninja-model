require 'spec_helper'

describe Symbol do
  subject { :foobar }
  it { should respond_to(:eq) }
  it { should respond_to(:ne) }
  it { should respond_to(:gt) }
  it { should respond_to(:gte) }
  it { should respond_to(:lt) }
  it { should respond_to(:lte) }
  it { should respond_to(:in) }
  its(:eq) { should be_kind_of(NinjaModel::Predicate) }
  its(:ne) { should be_kind_of(NinjaModel::Predicate) }
  its(:gt) { should be_kind_of(NinjaModel::Predicate) }
  its(:gte) { should be_kind_of(NinjaModel::Predicate) }
  its(:lt) { should be_kind_of(NinjaModel::Predicate) }
  its(:lte) { should be_kind_of(NinjaModel::Predicate) }
  its(:in) { should be_kind_of(NinjaModel::Predicate) }
end
