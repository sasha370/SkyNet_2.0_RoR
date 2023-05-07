# frozen_string_literal: true

module Commands
  # This class is responsible for handling /help command
  class HelpCommand
    def self.call
      kb = [[
        Telegram::Bot::Types::InlineKeyboardButton.new(text: I18n.t('commands.help.how_it_works'),
                                                       callback_data: 'how_it_works'),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: I18n.t('commands.help.restrictions'),
                                                       callback_data: 'restrictions'),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: I18n.t('commands.help.examples'),
                                                       callback_data: 'examples'),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: I18n.t('commands.help.voice_button'),
                                                       callback_data: 'voice_button'),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: I18n.t('commands.help.change_language'),
                                                       callback_data: 'change_language')
      ]]

      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
      [I18n.t('commands.help.choose_command'), markup.to_json]
    end
  end
end
