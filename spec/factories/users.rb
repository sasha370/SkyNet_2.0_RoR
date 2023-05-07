# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    is_bot { false }
    username { Faker::Internet.username }
    telegram_id { Faker::Number.number(digits: 10) }
    language_code { Faker::Nation.language }
    is_premium { false }
  end
end
