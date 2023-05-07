# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    event_type { 'Message' }
    chat_id { '1' }
    user
    data do
      { 'message_id' => 1,
        'from' => { 'id' => 1000,
                    'is_bot' => false,
                    'first_name' => 'Kyle',
                    'last_name' => 'Reese',
                    'username' => 'kyle_reese',
                    'language_code' => 'ru' },
        'date' => 1_683_455_464,
        'chat' => { 'id' => 2000,
                    'type' => 'private',
                    'username' => 'kyle_reese',
                    'first_name' => 'Kyle',
                    'last_name' => 'Reese' },
        'text' => 'Is 42 a correct answer?' }
    end

    trait :with_callback do
      event_type { 'CallbackQuery' }
      data do
        {
          'data' => 'how_it_works'
        }
      end
    end

    trait :with_voice do
      data do
        {
          'voice' => {
            duration: 1,
            mime_type: 'audio/ogg',
            file_id: 'WVhGkC8E',
            file_unique_id: 'AgADayYAAsMzwEo',
            file_size: 40_043
          }
        }
      end
    end

    trait :with_unknown_type do
      event_type { 'UnknownType' }
      data { { 'smt' => 42 } }
    end
  end
end
