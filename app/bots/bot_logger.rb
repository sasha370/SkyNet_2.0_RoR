# frozen_string_literal: true

# Base logger
module BotLogger
  def logger
    log_file = File.join('log', "#{Rails.env}-#{Time.zone.today}.log")

    @logger ||= Logger.new(log_file, 'daily')
    @logger.level = Rails.env.test? ? Logger::FATAL : Logger::INFO
    @logger.datetime_format = '%Y-%m-%d %H:%M:%S'
    @logger
  end
end
