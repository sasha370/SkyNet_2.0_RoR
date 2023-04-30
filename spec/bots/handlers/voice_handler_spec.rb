# frozen_string_literal: true

RSpec.describe Handlers::VoiceHandler do
  let(:handle_event) { described_class.process(event) }

  let(:ai_client) { instance_double(OpenaiClient) }
  let(:converter) { instance_double(OggToMp3ConverterService) }
  let(:mp3_file_path) { 'tmp/my_voice_message.mp3' }
  let(:ai_answer) { 'Hello world' }

  let(:voice_file) do
    Telegram::Bot::Types::Voice.new(file_unique_id: 'MyUniQId',
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

  before do
    allow(OggToMp3ConverterService).to receive(:new).and_return(converter)
    allow(converter).to receive(:convert).and_return(mp3_file_path)
    allow(converter).to receive(:clean_up)
    allow(OpenaiClient).to receive(:instance).and_return(ai_client)
    allow(ai_client).to receive(:transcribe).with(mp3_file_path).and_return(ai_answer)
  end

  describe '#call' do
    context 'when file converted successfully' do
      it 'returns transcription' do
        expect(ai_client).to receive(:transcribe).with(mp3_file_path)
        expect(converter).to receive(:clean_up)
        expect(handle_event).to eq(ai_answer)
      end
    end

    context 'when file converted with error' do
      before do
        allow(converter).to receive(:convert).and_return(nil)
      end

      it 'returns I18n message' do
        expect(ai_client).not_to receive(:transcribe).with(mp3_file_path)
        expect(handle_event).to eq(I18n.t('voice_handler.cant_convert_file'))
      end
    end
  end
end
