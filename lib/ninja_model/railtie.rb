require 'ninja_model'
require 'rails/all'

module NinjaModel
  class Railtie < Rails::Railtie

    config.ninja_model = NinjaModel::Configuration.create

    config.generators.orm :ninja_model, :migration => false

    initializer 'ninja_model.logger' do |app|
      NinjaModel::set_logger(Rails.logger)
    end

    config.after_initialize do |app|
      config_path = File.join(Rails.root, app.config.ninja_model.config_file_path)
      if File.exists?(config_path)
        require 'erb'
        require 'yaml'
        app.config.ninja_model.specs = YAML::load(ERB.new(IO.read(config_path)).result)
        NinjaModel::Base.set_adapter
      else
        NinjaModel.logger.warn "[ninja-model] *WARNING* Unable to find configuration file at #{config_path}"
      end
    end
  end
end
