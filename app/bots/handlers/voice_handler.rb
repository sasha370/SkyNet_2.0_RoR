# frozen_string_literal: true

require 'httparty'
require 'streamio-ffmpeg'

module Handlers
  # This class is responsible for downloading the file,
  # converting it to wav and sending it to the OpenAI API for transcription
  class VoiceHandler
    include BotLogger

    attr_reader :ai_client, :tg_bot_client, :event

    def initialize(event, ai_client, tg_bot_client)
      @event = event
      @ai_client = ai_client
      @tg_bot_client = tg_bot_client
    end

    def call
      download_file
      return transcribe_audio if convert_ogg_to_mp3

      I18n.t('voice_handler.cant_convert_file')
    ensure
      clean_up
    end

    private

    def download_file
      download_url = "https://api.telegram.org/file/bot#{ENV.fetch('TELEGRAM_BOT_TOKEN', nil)}" \
                     "/#{file['result']['file_path']}"
      response = HTTParty.get(download_url)

      File.binwrite(file_name_ogg, response.body)
    end

    def convert_ogg_to_mp3
      logger.info("[CONVERTING FILE] #{file_name_ogg} to #{file_name_mp3}")
      audio = FFMPEG::Movie.new(file_name_ogg)
      audio.transcode(file_name_mp3, { audio_codec: 'libmp3lame' })
      File.exist?(file_name_mp3)
    rescue FFMPEG::Error => e
      logger.error("[CONVERTING FILE] #{e.message}")
    end

    def transcribe_audio
      ai_client.transcribe(file_name_mp3)
    end

    def file
      # https://core.telegram.org/bots/api#getfile
      @file ||= tg_bot_client.api.get_file(file_id: event.voice.file_id)
    end

    def file_uniq_id
      file['result']['file_unique_id']
    end

    def file_name_ogg
      "tmp/#{file_uniq_id}.ogg"
    end

    def file_name_mp3
      "tmp/#{file_uniq_id}.mp3"
    end

    def clean_up
      [file_name_ogg, file_name_mp3].each { |file| FileUtils.rm_f(file) }
    end
  end
end
