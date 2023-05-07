# frozen_string_literal: true

module Handlers
  # This class is responsible for handling Messages from Telegram API (text, voice, etc.  )
  class MessageHandler < BaseHandler
    def call
      text = event.data['text']
      if text
        handle_text_message(text)
      elsif event.data['voice']
        process_voice_message
      else
        logger.info("[TYPE: text message UNKNOWN] #{event.inspect}")
        I18n.t('message_handler.dont_understand')
      end
    end

    private

    def handle_text_message(text)
      if text.start_with?('/help')
        logger.info("[TYPE: command] #{text}")
        # TODO: add CommandHandler and parse type of command inside it
        Commands::HelpCommand.call
      else
        logger.info("[TYPE: text message] #{text}")
        ask(text)
      end
    end

    def process_voice_message
      question = VoiceHandler.new(event).call
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
