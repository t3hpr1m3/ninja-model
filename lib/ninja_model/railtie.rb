module NinjaModel
  class Railtie < Rails::Railtie

    config.ninja_model = NinjaModel.configuration

    config.app_middleware.insert_after "::ActionDispatch::Callbacks",
      "NinjaModel::Adapters::AdapterManagement"

    initializer 'ninja_model.logger' do |app|
      NinjaModel::set_logger(Rails.logger)
    end

    initializer 'ninja_model_extend_active_record' do |app|
      ActiveSupport.on_load(:active_record) do
        require 'ninja_model/rails_ext/active_record'
      end
    end

    initializer 'ninja_model_load_specs' do |app|
      config_path = File.join(app.paths.config.to_a.first, "ninja_model.yml")
      if File.exists?(config_path)
        require 'erb'
        require 'yaml'
        app.config.ninja_model.specs = YAML::load(ERB.new(IO.read(config_path)).result)
      else
        NinjaModel.logger.warn "[ninja-model] *WARNING* Unable to find configuration file at #{config_path}"
      end
    end

    config.after_initialize do |app|
    end
  end
end
