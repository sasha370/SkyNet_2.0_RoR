# frozen_string_literal: true

require 'singleton'

# This class is responsible for making requests to the OpenAI API
class OpenaiClient
  include Singleton
  include BotLogger

  AI_TOKEN = ENV.fetch('OPENAI_TOKEN', nil)

  attr_reader :client

  def initialize
    @client = OpenAI::Client.new(access_token: AI_TOKEN)
  end

  def ask(text)
    response = client.chat(
      parameters: {
        model: 'gpt-3.5-turbo', # Required.
        messages: [{ role: 'user', content: text }], # Required.
        temperature: 0.7
      }
    )

    return response.dig('choices', 0, 'message', 'content') unless response['error']

    # TODO: handle error
    "Error: #{response['error']}"
  end

  def transcribe(file)
    response = client.transcribe(
      parameters: {
        model: 'whisper-1',
        file: File.open(file, 'rb')
      }
    )

    logger.info("[TRANSCRIBED RESPONSE] #{response}")
    return response['text'] unless response['error']

    # TODO: handle error
    "Error: #{response['error']}"
  end
end
