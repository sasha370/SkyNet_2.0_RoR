# frozen_string_literal: true

RSpec.describe Handlers::MessageHandler do
  let(:handle_event) { described_class.process(event) }

  let(:tg_bot_client) { instance_double(Telegram::Bot::Client) }
  let(:ai_client) { instance_double(OpenaiClient) }
  let(:ai_response) { 'I can hear you, don\'t scream!' }
  let(:event) { create(:event) }

  before do
    allow_any_instance_of(described_class).to receive(:ai_client).and_return(ai_client) # rubocop:disable RSpec/AnyInstance
    allow(ai_client).to receive(:ask).and_return(ai_response)
  end

  context 'when message is a command' do
    context 'when command is /help' do
      let(:message_text) { '/help' }
      let(:answer) { ['Choose command:', 'some markup'] }

      before do
        allow(Commands::HelpCommand).to receive(:call).and_return(answer)
        event.data['text'] = message_text
      end

      it 'calls handle_commands' do
        expect(ai_client).not_to receive(:ask).with(message_text)
        expect(handle_event).to eq(answer)
      end
    end
  end

  context 'when message is a question' do
    let(:message_text) { 'Here is my text question' }

    it 'calls handle_commands' do
      expect(ai_client).to receive(:ask).with(event.data['text'])
      expect(handle_event).to eq(ai_response)
    end
  end

  context 'when the message is a voice' do
    let(:voice_handler) { instance_double(Handlers::VoiceHandler) }
    let(:event) { create(:event, :with_voice) }

    before do
      allow(tg_bot_client).to receive(:api)
      allow(tg_bot_client.api).to receive(:get_file).and_return({ file_path: 'fake_file_path' })
      allow(Handlers::VoiceHandler).to receive(:new).and_return(voice_handler)
      allow(voice_handler).to receive(:call).and_return('Here is my question')
    end

    it 'calls process_voice_message and ask_ai' do
      expect(ai_client).to receive(:ask).with('Here is my question')
      expect(handle_event).to eq(ai_response)
    end
  end

  context 'when the message is neither text nor voice' do
    let(:event) { create(:event, :with_unknown_type) }

    it 'returns an error message' do
      expect(handle_event).to eq(I18n.t('message_handler.dont_understand'))
    end
  end
end
