# frozen_string_literal: true

module Handlers
  # This class is responsible for downloading the file,
  # converting it to wav and sending it to the OpenAI API for transcription
  class VoiceHandler < BaseHandler
    def call
      converted_file_path = converter.convert

      return transcribe_audio(converted_file_path) if converted_file_path

      I18n.t('voice_handler.cant_convert_file')
    ensure
      converter.clean_up
    end

    private

    def transcribe_audio(mp3_file_path)
      ai_client.transcribe(mp3_file_path)
    end

    def converter
      @converter ||= OggToMp3ConverterService.new(event)
    end

    def ai_client
      @ai_client ||= OpenaiClient.instance
    end
  end
end
