# frozen_string_literal: true

# Parse event and create user if it doesn't exist
# TODO: move it to workers
class EventParser
  include BotLogger
  def self.call(raw_event)
    new(raw_event).call
  end

  def initialize(raw_event)
    @raw_event = raw_event
  end

  def call # rubocop:disable Metrics/AbcSize
    Event.create(
      event_type: raw_event.class.name.split('::').last,
      chat_id: raw_event.chat.id,
      data: raw_event.to_json,
      user_id: find_or_create_user(raw_event).id
    )
  rescue StandardError => e
    logger.error("[CREATE EVENT FAILED] #{e.message}")
    nil
  end

  private

  attr_reader :raw_event

  def find_or_create_user(raw_event)
    User.find_or_create_by(telegram_id: raw_event.from.id) do |user|
      user.attributes = user_params(raw_event)
    end
  rescue StandardError => e
    logger.error("[CREATE USER FAILED] #{e.message}")
  end

  def user_params(raw_event)
    user = raw_event.from
    {
      telegram_id: user.try(:id),
      first_name: user.try(:first_name),
      last_name: user.try(:last_name),
      username: user.try(:username),
      language_code: user.try(:language_code),
      is_bot: user.try(:is_bot),
      is_premium: user.try(:is_premium)
    }
  end
end
