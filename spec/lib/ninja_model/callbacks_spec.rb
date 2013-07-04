require 'spec_helper'

describe NinjaModel::Callbacks do
  let(:adapter) { mock('Adapter') }
  class CallbackModel < NinjaModel::Base
    attribute :testing, :integer

    before_validation :before_validation_callback
    after_validation :after_validation_callback

    before_save :before_save_callback
    after_save :after_save_callback
    around_save :around_save_callback

    before_create :before_create_callback
    after_create :after_create_callback
    around_create :around_create_callback

    before_update :before_update_callback
    after_update :after_update_callback
    around_update :around_update_callback

    before_destroy :before_destroy_callback
    after_destroy :after_destroy_callback
    around_destroy :around_destroy_callback

    def before_validation_callback; true; end
    def after_validation_callback; true; end

    def before_save_callback; true; end
    def after_save_callback; true; end
    def around_save_callback; yield; end

    def before_create_callback; true; end
    def after_create_callback; true; end
    def around_create_callback; yield; end

    def before_update_callback; true; end
    def after_update_callback; true; end
    def around_update_callback; yield; end

    def before_destroy_callback; true; end
    def after_destroy_callback; true; end
    def around_destroy_callback; yield; end
  end

  before {
    @obj = CallbackModel.new
    @obj.class.stubs(adapter: adapter)
  }

  describe 'save' do
    context 'on a new record' do
      before do
        @obj.stubs(new_record?: true)
        adapter.stubs(create: true)
      end

      it 'should call the before_validation callback' do
        @obj.expects(:before_validation_callback)
        @obj.save
      end
      it 'should call the after_validation callback' do
        @obj.expects(:after_validation_callback)
        @obj.save
      end

      it 'should call the before_create callback' do
        @obj.expects(:before_create_callback)
        @obj.save
      end
      it 'should call the after_create callback' do
        @obj.expects(:after_create_callback)
        @obj.save
      end
      it 'should call the around_create callback' do
        @obj.expects(:around_create_callback).yields
        @obj.save
      end

      it 'should call the before_save callback' do
        @obj.expects(:before_save_callback)
        @obj.save
      end
      it 'should call the after_save callback' do
        @obj.expects(:after_save_callback)
        @obj.save
      end
      it 'should call the around_save callback' do
        @obj.expects(:around_save_callback).yields
        @obj.save
      end

      it 'should not call the before_update_callback' do
        @obj.expects(:before_update_callback).never
        @obj.save
      end
      it 'should not call the after_update_callback' do
        @obj.expects(:after_update_callback).never
        @obj.save
      end
      it 'should not call the around_update_callback' do
        @obj.expects(:around_update_callback).never
        @obj.save
      end

      it 'should not call the before_destroy_callback' do
        @obj.expects(:before_destroy_callback).never
        @obj.save
      end
      it 'should not call the after_destroy_callback' do
        @obj.expects(:after_destroy_callback).never
        @obj.save
      end
      it 'should not call the around_destroy_callback' do
        @obj.expects(:around_destroy_callback).never
        @obj.save
      end
    end

    context 'on an existing record' do
      before do
        @obj.stubs(new_record?: false)
        adapter.stubs(update: true)
      end

      it 'should call the before_validation callback' do
        @obj.expects(:before_validation_callback)
        @obj.save
      end
      it 'should call the after_validation callback' do
        @obj.expects(:after_validation_callback)
        @obj.save
      end

      it 'should not call the before_create callback' do
        @obj.expects(:before_create_callback).never
        @obj.save
      end
      it 'should not call the after_create callback' do
        @obj.expects(:after_create_callback).never
        @obj.save
      end
      it 'should not call the around_create callback' do
        @obj.expects(:around_create_callback).never
        @obj.save
      end

      it 'should call the before_save callback' do
        @obj.expects(:before_save_callback)
        @obj.save
      end
      it 'should call the after_save callback' do
        @obj.expects(:after_save_callback)
        @obj.save
      end
      it 'should call the around_save callback' do
        @obj.expects(:around_save_callback).yields
        @obj.save
      end

      it 'should call the before_update_callback' do
        @obj.expects(:before_update_callback)
        @obj.save
      end
      it 'should call the after_update_callback' do
        @obj.expects(:after_update_callback)
        @obj.save
      end
      it 'should call the around_update_callback' do
        @obj.expects(:around_update_callback)
        @obj.save
      end

      it 'should not call the before_destroy_callback' do
        @obj.expects(:before_destroy_callback).never
        @obj.save
      end
      it 'should not call the after_destroy_callback' do
        @obj.expects(:after_destroy_callback).never
        @obj.save
      end
      it 'should not call the around_destroy_callback' do
        @obj.expects(:around_destroy_callback).never
        @obj.save
      end
    end
  end

  describe 'destroy' do
    before do
      @obj.stubs(new_record?: false)
      adapter.stubs(destroy: true)
    end

    it 'should not call the before_validation callback' do
      @obj.expects(:before_validation_callback).never
      @obj.destroy
    end
    it 'should not call the after_validation callback' do
      @obj.expects(:after_validation_callback).never
      @obj.destroy
    end

    it 'should not call the before_create callback' do
      @obj.expects(:before_create_callback).never
      @obj.destroy
    end
    it 'should not call the after_create callback' do
      @obj.expects(:after_create_callback).never
      @obj.destroy
    end
    it 'should not call the around_create callback' do
      @obj.expects(:around_create_callback).never
      @obj.destroy
    end

    it 'should not call the before_save callback' do
      @obj.expects(:before_save_callback).never
      @obj.destroy
    end
    it 'should not call the after_save callback' do
      @obj.expects(:after_save_callback).never
      @obj.destroy
    end
    it 'should not call the around_save callback' do
      @obj.expects(:around_save_callback).never
      @obj.destroy
    end

    it 'should not call the before_update_callback' do
      @obj.expects(:before_update_callback).never
      @obj.destroy
    end
    it 'should not call the after_update_callback' do
      @obj.expects(:after_update_callback).never
      @obj.destroy
    end
    it 'should not call the around_update_callback' do
      @obj.expects(:around_update_callback).never
      @obj.destroy
    end

    it 'should call the before_destroy_callback' do
      @obj.expects(:before_destroy_callback)
      @obj.destroy
    end
    it 'should call the after_destroy_callback' do
      @obj.expects(:after_destroy_callback)
      @obj.destroy
    end
    it 'should call the around_destroy_callback' do
      @obj.expects(:around_destroy_callback).yields
      @obj.destroy
    end
  end
end
