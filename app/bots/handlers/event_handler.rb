# frozen_string_literal: true

module Handlers
  # This class is responsible for handling All events from Telegram API
  class EventHandler < BaseHandler
    def call # rubocop:disable Metrics/AbcSize
      log_event(event)
      if event.event_type == 'CallbackQuery'
        answer = CallbackHandler.process(event)
        [event.chat_id, answer]
      elsif event.event_type == 'Message'
        answer, reply_markup = MessageHandler.process(event)
        [event.chat_id, answer, reply_markup]
      else
        [event.chat_id, I18n.t('event_handler.unsupported_event')]
      end
    end

    private

    def log_event(event)
      logger.info("[NEW EVENT]: #{event.event_type}. " \
                  "User: #{event.user.first_name} #{event.user.last_name}, login:  #{event.user.username}")
    end
  end
end
