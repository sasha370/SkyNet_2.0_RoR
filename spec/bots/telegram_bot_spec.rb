# frozen_string_literal: true

RSpec.describe TelegramBot do
  let(:token) { 'fake_token' }
  let(:telegram_bot) { described_class.new(token) }

  describe '#initialize' do
    it 'sets the token instance variable' do
      expect(telegram_bot.instance_variable_get(:@token)).to eq(token)
    end
  end

  describe '#listen' do
    let(:client) { instance_double(Telegram::Bot::Client) }
    let(:event_handler) { instance_double(Handlers::EventHandler) }
    let(:message_data)  do
      { message_id: 1,
        date: 1,
        text: 'Hello, world!',
        chat: { id: 1, type: 'type' } }
    end
    let(:event) { Telegram::Bot::Types::Message.new(message_data) }
    let(:answer) { [event.chat.id, 'Hello, world!'] }

    before do
      allow(telegram_bot).to receive(:client).and_return(client)
      allow(client).to receive(:listen).and_yield(event)
      allow(Handlers::EventHandler).to receive(:process).and_return(answer)
      allow(client).to receive(:api)
    end

    it 'calls the event handler' do
      expect(Handlers::EventHandler).to receive(:process).with(event)
      expect(client.api).to receive(:send_message).with(chat_id: answer.first,
                                                        text: answer.last,
                                                        reply_markup: nil)
      telegram_bot.run
    end
  end
end
