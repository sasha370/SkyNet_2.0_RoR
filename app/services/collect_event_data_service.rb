# frozen_string_literal: true

# Service for collecting event data
# TODO: move it to workers
class CollectEventDataService
  def self.call(event)
    new(event).call
  end

  def initialize(event)
    @event = event
  end

  def call
    user = parse_user(event)
    user.events.create(
      event_type: event.class.name.split('::').last,
      chat_id: event.chat.id,
      data: event.to_json
    )
  rescue StandardError => e
    logger.error("[CREATE EVENT FAILED] #{e.message}")
  end

  private

  attr_reader :event

  def parse_user(event)
    User.find_or_create_by(telegram_id: event.from.id) do |user|
      user.attributes = user_params(event)
    end
  rescue StandardError => e
    logger.error("[CREATE USER FAILED] #{e.message}")
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
