# frozen_string_literal: true

# Class: User
class User < ApplicationRecord
  has_many :events, dependent: :destroy
end
