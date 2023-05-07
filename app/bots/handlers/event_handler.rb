# frozen_string_literal: true

module Handlers
  # This class is responsible for handling All events from Telegram API
  class EventHandler < BaseHandler
    def call
      log_event(event)
      if event.event_type == 'CallbackQuery'
        CallbackHandler.process(event)
      elsif event.event_type == 'Message'
        MessageHandler.process(event)
      else
        UnknownTypeHandler.process(event)
      end
    end

    private

    def log_event(event)
      logger.info("[NEW EVENT]: #{event.event_type}. " \
                  "User: #{event.user.first_name} #{event.user.last_name}, login:  #{event.user.username}")
    end
  end
end
