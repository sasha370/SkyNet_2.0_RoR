# frozen_string_literal: true

module Handlers
  # This is Base class for all handlers
  class BaseHandler
    include BotLogger

    def self.process(event)
      new(event).call
    end

    def call
      raise NotImplementedError
    end

    private

    attr_reader :event

    def initialize(event)
      @event = event
    end
  end
end
