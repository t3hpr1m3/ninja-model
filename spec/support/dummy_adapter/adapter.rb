module DummyAdapter
  class Adapter < NinjaModel::Adapters::AbstractAdapter
    extend ActiveSupport::Autoload

    def initilalize(config, logger = nil)
      super
      @active = false
    end

    def reconnect!
      disconnect!
      connect
    end

    def disconnect!
      nil
    end

    def connect
    end

    def create(model)
      execute :create, model
    end

    def read(query)
      execute :read, query
    end

    def update(model)
      execute :update, model
    end

    def destroy(model)
      execute :destroy, model
    end

    def reload(model)
      execute :reload, model
    end

    private

    def execute(method, object)
      raise NotImplementedError, "I should have been stubbed!"
    end
  end
end
