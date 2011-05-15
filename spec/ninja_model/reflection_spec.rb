require 'spec_helper'
describe NinjaModel::Reflection do
  class BareModel
  end
  class ReflectionModel < NinjaModel::Base
    attribute :test, :string
  end
  class TargetModel < NinjaModel::Base
    attribute :test2, :string
  end

  subject { ReflectionModel }
  it { should respond_to(:create_reflection) }

  describe 'ninja_model?' do
    specify { NinjaModel::Base.ninja_model?(:has_one, :bare_model).should be_false }
    specify { NinjaModel::Base.ninja_model?(:has_one, :reflection_model).should be_true }
  end

  describe 'create_reflection' do
    it 'should store the reflections on the class' do
      @klass = Class.new(NinjaModel::Base)
      @reflection = @klass.create_reflection(:has_one, :target_model, {}, @klass)
      @klass.reflections.should eql(:target_model => @reflection)
    end

    it 'should return a reflection for a particular association' do
      @klass = Class.new(NinjaModel::Base)
      @reflection = @klass.create_reflection(:has_one, :target_model, {}, @klass)
      @klass.reflect_on_association(:target_model).should eql(@reflection)
    end

    context 'has_one' do
      subject { ReflectionModel.create_reflection(:has_one, :target_model, {}, ReflectionModel) }
      its(:class_name) { should eql('TargetModel') }
      its(:klass) { should eql(TargetModel) }
      its(:collection?) { should be_false }
      its(:primary_key_name) { should eql('reflection_model_id') }
      its(:association_foreign_key) { should eql('target_model_id') }
      its(:belongs_to?) { should be_false }
    end

    context 'has_many' do
      subject { ReflectionModel.create_reflection(:has_many, :target_models, {}, ReflectionModel) }
      its(:class_name) { should eql('TargetModel') }
      its(:klass) { should eql(TargetModel) }
      its(:collection?) { should be_true }
      its(:primary_key_name) { should eql('reflection_model_id') }
      its(:association_foreign_key) { should eql('target_model_id') }
      its(:belongs_to?) { should be_false }
    end

    context 'belongs_to' do
      subject { TargetModel.create_reflection(:belongs_to, :reflection_model, {}, TargetModel) }
      its(:class_name) { should eql('ReflectionModel') }
      its(:klass) { should eql(ReflectionModel) }
      its(:collection?) { should be_false }
      its(:primary_key_name) { should eql('reflection_model_id') }
      its(:association_foreign_key) { should eql('reflection_model_id') }
      its(:belongs_to?) { should be_true }
    end
  end
end
