# frozen_string_literal: true

require 'telegram/bot'
require_relative 'bot_logger'

# This class is responsible for listening to messages and sending answers for Telegram Bot
class TelegramBot
  include BotLogger
  def initialize(token)
    @token = token
  end

  def run
    client.listen do |event|
      chat_id, answer, reply_markup = event_handler.process(event)
      logger.info("[EVENT ANSWER] #{answer}")

      send_answer(chat_id:, answer:, reply_markup:)
    end
  end

  private

  def event_handler
    @event_handler ||= Handlers::EventHandler.new(client)
  end

  def send_answer(chat_id:, answer:, reply_markup: nil)
    client.api.send_message(chat_id:, text: answer, reply_markup:)
  end

  def client
    @client ||= Telegram::Bot::Client.new(@token)
  end
end
