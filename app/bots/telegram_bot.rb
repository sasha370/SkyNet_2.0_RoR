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
      parse_user(event)
      chat_id, answer, reply_markup = process_event(event)
      logger.info("[EVENT ANSWER] #{answer}")
      send_answer(chat_id:, answer:, reply_markup:)
    end
  end

  private

  def parse_user(event)
    return if User.find_by(telegram_id: event.from.id)

    User.create(user_params(event))
  rescue StandardError => e
    logger.error("[CREATE USER FAILED] #{e.message}")
  end

  def process_event(event)
    Handlers::EventHandler.process(event)
  end

  def send_answer(chat_id:, answer:, reply_markup: nil)
    client.api.send_message(chat_id:, text: answer, reply_markup:)
  end

  def client
    @client ||= Telegram::Bot::Client.new(@token)
  end

  def user_params(event)
    {
      telegram_id: event.from.id,
      first_name: event.from.first_name,
      last_name: event.from.last_name,
      username: event.from.username,
      language_code: event.from.language_code,
      is_bot: event.from.is_bot,
      is_premium: event.from.is_premium
    }
  end
end
