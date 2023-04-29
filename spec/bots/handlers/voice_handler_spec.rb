# frozen_string_literal: true

RSpec.describe Handlers::VoiceHandler do
  let(:handle_event) { described_class.new(event, ai_client, tg_bot_client) }

  let(:ai_client) { instance_double(OpenaiClient) }
  let(:tg_bot_client) { instance_double(Telegram::Bot::Client) }

  let(:voice_file) do
    Telegram::Bot::Types::Voice.new(file_unique_id: 'test_file_id',
                                    file_id: '123',
                                    duration: 10)
  end
  let(:message_data) do
    { message_id: 1,
      voice: voice_file,
      date: 1,
      chat: { id: 1, type: 'type' } }
  end
  let(:event) { Telegram::Bot::Types::Message.new(message_data) }
  let(:file) { { 'result' => { 'file_path' => 'test/file/path', 'file_unique_id' => 'test_file_id' } } }

  before do
    allow(tg_bot_client).to receive(:api)
    allow(tg_bot_client.api).to receive(:get_file).and_return(file)
  end

  describe '#call' do
    context 'when file is downloaded and converted successfully' do
      before do
        allow(handle_event).to receive(:download_file)
        allow(handle_event).to receive(:convert_ogg_to_mp3).and_return(true)
        allow(handle_event).to receive(:transcribe_audio).and_return('transcription')
      end

      it 'downloads the file' do
        expect(handle_event).to receive(:download_file)
        handle_event.call
      end

      it 'converts the file' do
        expect(handle_event).to receive(:convert_ogg_to_mp3)
        handle_event.call
      end

      it 'returns the transcription' do
        expect(handle_event.call).to eq('transcription')
      end

      it 'cleans up the temporary files' do
        expect(handle_event).to receive(:clean_up)
        handle_event.call
      end
    end

    context 'when file conversion fails' do
      before do
        allow(handle_event).to receive(:download_file)
        allow(handle_event).to receive(:convert_ogg_to_mp3).and_return(false)
      end

      it 'downloads the file' do
        expect(handle_event).to receive(:download_file)
        handle_event.call
      end

      it 'does not transcribe the file' do
        expect(handle_event).not_to receive(:transcribe_audio)
        handle_event.call
      end

      it 'returns a failure message' do
        expect(handle_event.call).to eq(I18n.t('voice_handler.cant_convert_file'))
      end

      it 'cleans up the temporary files' do
        expect(handle_event).to receive(:clean_up)
        handle_event.call
      end
    end
  end
end
