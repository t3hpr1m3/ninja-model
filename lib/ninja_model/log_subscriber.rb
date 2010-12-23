module NinjaModel
  class LogSubscriber < ActiveSupport::LogSubscriber
    def xml(event)
      return unless logger.debug?

      name = '%s (%.1fms)' % [event.payload[:name], event.duration]
      xml = event.payload[:xml]

      debug "  #{name}  #{xml}"
    end

    def logger
      NinjaModel::Base.logger
    end
  end
end

ActiveRecord::LogSubscriber.attach_to :ninja_model
