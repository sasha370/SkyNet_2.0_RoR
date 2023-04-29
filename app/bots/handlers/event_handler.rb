# frozen_string_literal: true

module Handlers
  # This class is responsible for handling All events from Telegram API
  class EventHandler
    include BotLogger

    attr_reader :event, :tg_bot_client

    def initialize(tg_bot_client)
      @tg_bot_client = tg_bot_client
    end

    def process(event)
      log_event(event)
      if event.instance_of?(Telegram::Bot::Types::CallbackQuery)
        answer = CallbackHandler.process(event)
        [event.message.chat.id, answer]
      elsif event.instance_of?(Telegram::Bot::Types::Message)
        answer, reply_markup = MessageHandler.process(event, tg_bot_client)
        [event.chat.id, answer, reply_markup]
      else
        [event.message.chat.id, I18n.t('event_handler.unsupported_event')]
      end
    end

    private

    def log_event(event)
      if event.respond_to?(:from)
        logger.info("[NEW EVENT]: #{event.class}." \
          " User: #{event.from&.first_name} #{event.from&.last_name}, login:  #{event.from&.username}")
      else
        logger.warn("[UNKNOWN EVENT]: #{event.inspect}.")
      end
    end
  end
end
