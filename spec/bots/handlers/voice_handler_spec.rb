# frozen_string_literal: true

RSpec.describe Handlers::VoiceHandler do
  let(:handle_event) { described_class.process(event) }

  let(:ai_client) { instance_double(OpenaiClient) }
  let(:converter) { instance_double(OggToMp3ConverterService) }
  let(:mp3_file_path) { "tmp/#{event.data['voice']['file_id']}.mp3" }
  let(:ai_answer) { 'Hello world' }

  let(:event) { create(:event, :with_voice) }

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
