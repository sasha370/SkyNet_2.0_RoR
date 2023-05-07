# frozen_string_literal: true

RSpec.describe OggToMp3ConverterService do
  let(:convert_file) { described_class.new(event) }

  let(:event) { create(:event, :with_voice) }

  let(:file_id) { event.data['voice']['file_id'] }
  let(:file_uniq_id) { 'MyUniQId' }
  let(:client) { instance_double(Telegram::Bot::Client) }
  let(:converter) { instance_double(FFMPEG::Movie) }
  let(:file_data) { { 'result' => { 'file_path' => 'test/file/path', 'file_unique_id' => file_id } } }

  before do
    allow(Telegram::Bot::Client).to receive(:new).and_return(client)
    allow(client).to receive(:api)
    allow(client.api).to receive(:get_file).and_return(file_data)
    allow(Faraday).to receive(:get).and_return(Struct.new(:body).new(file_id))
    allow(FFMPEG::Movie).to receive(:new).and_return(converter)
    allow(converter).to receive(:transcode).and_return(true)
    allow(File).to receive(:binwrite).and_call_original
  end

  context 'when convert is success' do
    before do
      # emulate that file converted by FFmpeg successfully
      File.new("tmp/#{file_id}.mp3", 'w')
    end

    it 'returns path to mp3 file' do
      expect(File).to receive(:binwrite).with("tmp/#{file_id}.ogg", file_id)

      expect(convert_file.convert).to eq("tmp/#{file_id}.mp3")
    end
  end

  describe 'when converting is not success' do
    context 'when file not converted by FFmpeg' do
      before do
        # cleanup tmp
        FileUtils.rm_f("tmp/#{file_id}.mp3")
        allow(converter).to receive(:transcode).and_raise(FFMPEG::Error)
      end

      it 'returns nil' do
        expect(File).to receive(:binwrite).with("tmp/#{file_id}.ogg", file_id)

        expect(convert_file.convert).to be_nil
      end
    end

    context 'when error during downloading file' do
      before do
        allow(Faraday).to receive(:get).and_raise(Faraday::Error)
      end

      it 'returns nil' do
        expect(File).not_to receive(:binwrite).with("tmp/#{file_id}.ogg", file_id)

        expect(convert_file.convert).to be_nil
      end
    end
  end

  describe '.clean_up' do
    before do
      # emulate that file converted by FFmpeg successfully
      File.new("tmp/#{file_id}.mp3", 'w')
    end

    it 'removes files' do
      expect(FileUtils).to receive(:rm_f).with("tmp/#{file_id}.ogg")
      expect(FileUtils).to receive(:rm_f).with("tmp/#{file_id}.mp3")

      convert_file.clean_up
    end
  end
end
