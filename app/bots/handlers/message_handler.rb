# frozen_string_literal: true

module Handlers
  # This class is responsible for handling Messages from Telegram API (text, voice, etc.  )
  class MessageHandler
    include BotLogger

    def self.process(event, tg_bot_client)
      new(event, tg_bot_client).call
    end

    def call
      if event.try(:text)
        handle_text_message
      elsif event.try(:voice)
        process_voice_message
      else
        logger.info("[TYPE: text message UNKNOWN] #{event.inspect}")
        I18n.t('message_handler.dont_understand')
      end
    end

    private

    attr_reader :event, :tg_bot_client

    def initialize(event, tg_bot_client)
      @event = event
      @tg_bot_client = tg_bot_client
    end

    def handle_text_message
      if event.text.start_with?('/help')
        logger.info("[TYPE: command] #{event.text}")
        # TODO: add CommandHandler and parse type of command inside it
        HelpCommand.call
      else
        logger.info("[TYPE: text message] #{event.text}")
        ask(event.text)
      end
    end

    def process_voice_message
      question = VoiceHandler.new(event, ai_client, tg_bot_client).call
      logger.info("[TYPE: voice message] #{question}")
      ask(question)
    end

    def ask(text)
      ai_client.ask(text)
    end

    def ai_client
      @ai_client ||= OpenaiClient.instance
    end
  end
end