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
    let(:event) { create(:event) }
    let(:answer) { event.answer }

    before do
      allow(telegram_bot).to receive(:client).and_return(client)
      allow(client).to receive(:listen).and_yield(event)
      allow(EventParser).to receive(:call).and_return(event)
      allow(Handlers::EventHandler).to receive(:process).and_return(answer)
      allow(client).to receive(:api)
    end

    it 'calls the event handler' do
      expect(Handlers::EventHandler).to receive(:process).with(event)
      expect(client.api).to receive(:send_message).with(chat_id: answer.chat_id,
                                                        text: answer.text,
                                                        reply_markup: answer.reply_markup)
      telegram_bot.run
    end

    context 'when event parsed with error' do
      before do
        allow(EventParser).to receive(:call).and_return(nil)
      end

      it 'does not call the event handler' do
        expect(Handlers::EventHandler).not_to receive(:process)
        expect(client.api).not_to receive(:send_message)
        telegram_bot.run
      end
    end
  end
end
