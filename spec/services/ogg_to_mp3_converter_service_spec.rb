# frozen_string_literal: true

RSpec.describe OggToMp3ConverterService do
  let(:convert_file) { described_class.new(event) }

  let(:event) do
    Telegram::Bot::Types::Message.new(message_id: 1,
                                      voice: voice_file,
                                      date: 1,
                                      chat: { id: 1, type: 'type' })
  end
  let(:voice_file) do
    Telegram::Bot::Types::Voice.new(file_unique_id: file_uniq_id,
                                    file_id:,
                                    duration: 10)
  end

  let(:file_id) { '123456' }
  let(:file_uniq_id) { 'MyUniQId' }
  let(:client) { instance_double(Telegram::Bot::Client) }
  let(:converter) { instance_double(FFMPEG::Movie) }
  let(:file_data) { { 'result' => { 'file_path' => 'test/file/path', 'file_unique_id' => '123456' } } }

  before do
    allow(Telegram::Bot::Client).to receive(:new).and_return(client)
    allow(client).to receive(:api)
    allow(client.api).to receive(:get_file).and_return(file_data)
    allow(Faraday).to receive(:get).and_return(Struct.new(:body).new('123'))
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
      expect(File).to receive(:binwrite).with("tmp/#{file_id}.ogg", '123')

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
        expect(File).to receive(:binwrite).with("tmp/#{file_id}.ogg", '123')

        expect(convert_file.convert).to be_nil
      end
    end

    context 'when error during downloading file' do
      before do
        allow(Faraday).to receive(:get).and_raise(Faraday::Error)
      end

      it 'returns nil' do
        expect(File).not_to receive(:binwrite).with("tmp/#{file_id}.ogg", '123')

        expect(convert_file.convert).to be_nil
      end
    end
  end
end
