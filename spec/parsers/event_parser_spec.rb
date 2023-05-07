# frozen_string_literal: true

RSpec.describe EventParser do
  let(:parse) { described_class.call(raw_event) }

  let(:raw_event) do
    Telegram::Bot::Types::Message.new(message_id: 1,
                                      date: 1,
                                      text: 'What if?',
                                      chat: { id: 1, type: 'type' },
                                      from: { id: 1,
                                              first_name: 'Kyle',
                                              last_name: 'Reese',
                                              username: 'kyle_reese',
                                              language_code: 'en',
                                              is_bot: true,
                                              is_premium: false })
  end

  describe '.call' do
    it 'creates event' do
      expect(Event).to receive(:create).with(
        event_type: 'Message',
        chat_id: 1,
        data: raw_event,
        user_id: an_instance_of(Integer)
      )
      parse
    end

    it 'creates User' do
      expect { parse }.to change(User, :count).by(1)
    end
  end

  describe 'when User exists' do
    let(:user) { create(:user, telegram_id: 1) }

    it 'does not create a new User' do
      expect(Event).to receive(:create).with(
        event_type: 'Message',
        chat_id: 1,
        data: raw_event,
        user_id: user.id
      )
      expect { parse }.not_to change(User, :count)
    end
  end
end
