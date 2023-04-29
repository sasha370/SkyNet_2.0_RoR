# frozen_string_literal: true

require 'httparty'

module Handlers
  # This class is responsible for downloading the file,
  # converting it to wav and sending it to the OpenAI API for transcription
  class VoiceHandler
    attr_reader :ai_client, :tg_bot_client, :event

    def initialize(event, ai_client, tg_bot_client)
      @event = event
      @ai_client = ai_client
      @tg_bot_client = tg_bot_client
    end

    def call
      download_file
      return transcribe_audio if convert_file

      I18n.t('voice_handler.cant_convert_file')
    ensure
      clean_up
    end

    private

    def download_file
      download_url = "https://api.telegram.org/file/bot#{ENV['TELEGRAM_BOT_TOKEN']}/#{file['result']['file_path']}"
      response = HTTParty.get(download_url)

      File.open(file_name_ogg, 'wb') { |file| file.write(response.body) }
    end

    def convert_file
      # file_name_ogg = 'tmp/AgADIy0AAiTLaEo.ogg'
      # file_name_wav = 'tmp/output.wav'
      system("ffmpeg -i #{file_name_ogg} -acodec pcm_s16le -ac 1 -ar 16000 #{file_name_wav} 2> /dev/null ")
      # Check if the file was converted
      File.exist?(file_name_wav)
    end

    def transcribe_audio
      ai_client.transcribe(file_name_wav)
    end

    def file
      # https://core.telegram.org/bots/api#getfile
      tg_bot_client.api.get_file(file_id: event.voice.file_id)
    end

    def file_uniq_id
      file['result']['file_unique_id']
    end

    def file_name_ogg
      "tmp/#{file_uniq_id}.ogg"
    end

    def file_name_wav
      "tmp/#{file_uniq_id}.wav"
    end

    def clean_up
      [file_name_ogg, file_name_wav].each { |file| File.delete(file) if File.exist?(file) }
    end
  end
end
