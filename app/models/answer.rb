# frozen_string_literal: true

# Class: Answer
class Answer < ApplicationRecord
  belongs_to :event

  validates :chat_id, presence: true
end
