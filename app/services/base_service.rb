# frozen_string_literal: true

# Base class for all services
class BaseService
  include BotLogger
  def self.call(*args)
    new(*args).call
  end

  def initialize(*_args); end
end
