# frozen_string_literal: true

require 'streamio-ffmpeg'

# Class responsible for converting ogg files to mp3
class OggToMp3ConverterService
  include BotLogger

  attr_reader :event

  def initialize(event)
    @event = event
  end

  def convert
    return unless download_file

    convert_ogg_to_mp3
    success? ? file_path_mp3 : nil
  rescue StandardError => e
    logger.error("[CONVERTING FILE ERROR] #{e.message}")
    nil
  end

  def clean_up
    [file_path_ogg, file_path_mp3].each { |file| FileUtils.rm_f(file) }
  rescue StandardError => e
    logger.error("[CLEANING UP ERROR] #{e.message}")
    nil
  end

  private

  def success?
    File.exist?(file_path_mp3)
  end

  def download_file
    download_url = "https://api.telegram.org/file/bot#{ENV.fetch('TELEGRAM_BOT_TOKEN', nil)}" \
                   "/#{file['result']['file_path']}"
    response = Faraday.get(download_url)

    File.binwrite(file_path_ogg, response.body)
  rescue StandardError => e
    logger.error("[DOWNLOADING FILE ERROR] #{e.message}")
    nil
  end

  def convert_ogg_to_mp3
    logger.info("[CONVERTING FILE] #{file_path_ogg} to #{file_path_mp3}")
    converter.transcode(file_path_mp3, { audio_codec: 'libmp3lame' })
  rescue FFMPEG::Error => e
    logger.error("[FFMPEG ERROR] #{e.message}")
  end

  def converter
    FFMPEG::Movie.new(file_path_ogg)
  end

  def file_uniq_id
    file['result']['file_unique_id']
  end

  def file_path_ogg
    "tmp/#{file_uniq_id}.ogg"
  end

  def file_path_mp3
    "tmp/#{file_uniq_id}.mp3"
  end

  def client
    @client ||= Telegram::Bot::Client.new(ENV.fetch('TELEGRAM_BOT_TOKEN', nil))
  end

  def file
    # https://core.telegram.org/bots/api#getfile
    client.api.get_file(file_id: event.voice.file_id)
  end
end
