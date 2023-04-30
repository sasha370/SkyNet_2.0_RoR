# frozen_string_literal: true

module Handlers
  # This class is responsible for handling All events from Telegram API
  class EventHandler
    include BotLogger

    def self.process(event)
      new(event).call
    end

    def call # rubocop:disable Metrics/AbcSize
      log_event(event)
      if event.instance_of?(Telegram::Bot::Types::CallbackQuery)
        answer = CallbackHandler.process(event)
        [event.message.chat.id, answer]
      elsif event.instance_of?(Telegram::Bot::Types::Message)
        answer, reply_markup = MessageHandler.process(event)
        [event.chat.id, answer, reply_markup]
      else
        [event.message.chat.id, I18n.t('event_handler.unsupported_event')]
      end
    end

    private

    attr_reader :event

    def initialize(event)
      @event = event
    end

    def log_event(event)
      if event.respond_to?(:from)
        logger.info("[NEW EVENT]: #{event.class}. " \
                    "User: #{event.from&.first_name} #{event.from&.last_name}, login:  #{event.from&.username}")
      else
        logger.warn("[UNKNOWN EVENT]: #{event.inspect}.")
      end
    end
  end
end
