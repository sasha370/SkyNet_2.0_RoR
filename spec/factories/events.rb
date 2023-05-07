# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    date { Faker::Date.between(from: 2.days.ago, to: 2.days.from_now) }
    user
  end
end
