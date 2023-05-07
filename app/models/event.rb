# frozen_string_literal: true

# Class: Event
class Event < ApplicationRecord
  belongs_to :user
  has_one :answer, dependent: :destroy

  validates :event_type, :chat_id, :data, presence: true
end
