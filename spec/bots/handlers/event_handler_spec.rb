# frozen_string_literal: true

RSpec.describe Handlers::EventHandler do
  let(:handle_event) { described_class.new(tg_bot_client).process(event) }

  let(:tg_bot_client) { instance_double(Telegram::Bot::Client) }
  let(:answer) { 'I can hear you, don\'t scream!' }
  let(:message_data) do
    { message_id: 1,
      date: 1,
      text: 'Hello, world!',
      chat: { id: 1, type: 'type' } }
  end
  let(:event) { Telegram::Bot::Types::Message.new(message_data) }

  describe 'when the event is a Message' do
    before do
      allow(Handlers::MessageHandler).to receive(:process).and_return(answer)
    end

    it 'calls handler and return answer' do
      expect(handle_event).to eq([event.chat.id, answer, nil])
      expect(Handlers::MessageHandler).to have_received(:process).with(event, tg_bot_client)
    end
  end

  describe 'when the event is a callback' do
    let(:message) { Telegram::Bot::Types::Message.new(message_data) }
    let(:user) { Telegram::Bot::Types::User.new(id: 1, first_name: 'John', last_name: 'Doe', is_bot: false) }
    let(:event) do
      Telegram::Bot::Types::CallbackQuery.new(id: '1',
                                              from: user,
                                              data: 'how_it_works',
                                              message:,
                                              chat_instance: '1')
    end
    let(:callback_answer) { 'Here is my callback answer' }

    before do
      allow(Handlers::CallbackHandler).to receive(:process).and_return(callback_answer)
    end

    it 'calls handle_callback' do
      expect(Handlers::CallbackHandler).to receive(:process).with(event)
      expect(handle_event).to eq([event.message.chat.id, callback_answer])
    end
  end

  describe 'when the event is unsupported' do
    let(:message) {  Telegram::Bot::Types::Message.new(message_data) }
    let(:event) { Telegram::Bot::Types::Update.new(update_id: 1, message:) }
    let(:answer) { I18n.t('event_handler.unsupported_event') }

    it 'calls handle_callback' do
      expect(handle_event).to eq([event.message.chat.id, answer])
    end
  end
end
