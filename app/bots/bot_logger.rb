# frozen_string_literal: true

# Base logger
module BotLogger
  def logger
    @logger ||= Logger.new($stdout)
    @logger.level = Rails.env.test? ? Logger::FATAL : Logger::INFO
    @logger.datetime_format = '%Y-%m-%d %H:%M:%S' # Формат даты и времени
    @logger
  end
end
