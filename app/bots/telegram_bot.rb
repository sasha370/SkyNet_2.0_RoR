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
    client.listen do |raw_event|
      event = parse_event(raw_event)
      if event
        process_event(event)
        send_answer(event.answer)
      end
    end
  end

  private

  def parse_event(event)
    EventParser.call(event)
  end

  def process_event(event)
    Handlers::EventHandler.process(event)
  end

  # TODO: Move it to separate class ~ TelegramBot::AnswerSender
  def send_answer(answer)
    client.api.send_message(chat_id: answer.chat_id, text: answer.text, reply_markup: answer.reply_markup)
  end

  def client
    @client ||= Telegram::Bot::Client.new(@token)
  end
end
