# frozen_string_literal: true

module Handlers
  # This class is responsible for handling callbacks from inline keyboard
  class CallbackHandler < BaseHandler
    def call # rubocop:disable Metrics/MethodLength
      logger.info("[TYPE: callback] #{event.data}")
      case event.data
      when 'how_it_works'
        I18n.t('callbacks.how_it_works_message')
      when 'restrictions'
        I18n.t('callbacks.restrictions_message')
      when 'examples'
        I18n.t('callbacks.examples_message')
      when 'voice_button'
        I18n.t('callbacks.voice_button')
      when 'change_language'
        I18n.locale = I18n.locale == :ru ? :en : :ru
        I18n.t('callbacks.language_changed_message')
      else
        I18n.t('callbacks.not_known_message')
      end
    end
  end
end
