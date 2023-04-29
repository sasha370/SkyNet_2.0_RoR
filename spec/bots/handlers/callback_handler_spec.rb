# frozen_string_literal: true

RSpec.describe Handlers::CallbackHandler do
  describe '.process' do
    let(:handle_event) { described_class.process(event) }

    let(:message_data) do
      { message_id: 1,
        date: 1,
        text: 'Hello, world!',
        chat: { id: 1, type: 'type' } }
    end
    let(:message) { Telegram::Bot::Types::Message.new(message_data) }
    let(:user) { Telegram::Bot::Types::User.new(id: 1, first_name: 'John', last_name: 'Doe', is_bot: false) }
    let(:event) do
      Telegram::Bot::Types::CallbackQuery.new(id: '1',
                                              from: user,
                                              data: callback,
                                              message:,
                                              chat_instance: '1')
    end

    describe 'all supported callbacks' do
      %w[how_it_works restrictions examples].each do |callback|
        let(:callback) { callback }

        it 'returns a string for all supported callbacks' do
          expect(handle_event).to be_a(String)
        end
      end
    end

    describe 'not supported callback' do
      let(:callback) { 'not_supported' }

      it 'returns a string for all supported callbacks' do
        expect(handle_event).to eq('Я не знаю такой команды. Попробуйте еще раз')
      end
    end
  end
end
