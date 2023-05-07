# frozen_string_literal: true

module Handlers
  # This class is responsible for handling Messages from Telegram API (text, voice, etc.  )
  class UnknownTypeHandler < BaseHandler
    def call
      logger.info("[UNKNOWN EVENT TYPE] #{event.inspect}")
      update_answer(I18n.t('event_handler.unsupported_event'))
    end
  end
end
