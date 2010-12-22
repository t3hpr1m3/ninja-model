module NinjaModel

  mattr_accessor :configuration

  class Configuration
    attr_accessor :config_file_path, :adapter_path, :specs

    def self.create
      NinjaModel.configuration ||= new
    end

    private

    def initialize
      @config_file_path = 'config/ninja_model.yml'
      @adapter_path = 'ninja_model/adapters'
      @specs = {}
    end
  end
end
