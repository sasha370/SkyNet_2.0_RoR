# frozen_string_literal: true

RSpec.describe OpenaiClient do
  let(:client) { described_class.instance }

  let(:ai_client) { instance_double(OpenAI::Client) }
  let(:response_answer) { 'test answer' }
  let(:response) do
    { 'id' => 'chatcmpl-7AfLFhODydIwQ8IudSlMajzr1JWG6',
      'object' => 'chat.completion',
      'created' => 1_682_776_553,
      'model' => 'gpt-3.5-turbo-0301',
      'usage' => { 'prompt_tokens' => 9, 'completion_tokens' => 60, 'total_tokens' => 69 },
      'choices' =>
       [{ 'message' =>
           { 'role' => 'assistant',
             'content' => response_answer,
             'finish_reason' => 'stop',
             'index' => 0 } }] }
  end

  before do
    client.instance_variable_set('@client', ai_client)
    allow(OpenAI::Client).to receive(:new).and_return(ai_client)
    allow(ai_client).to receive(:chat).and_return(response)
  end

  describe '#ask_ai' do
    context 'when successful' do
      it 'returns the response content' do
        expect(client.ask('2+2')).to eq(response_answer)
      end
    end

    context 'when unsuccessful' do
      let(:response) { { 'error' => 'test error' } }

      it 'returns an error message' do
        expect(client.ask('test')).to eq('Error: test error')
      end
    end
  end

  describe '#transcribe' do
    before do
      allow(File).to receive(:open).and_return(StringIO.new('file_contents'))
      allow(ai_client).to receive(:transcribe).and_return(response)
    end

    context 'when successful' do
      let(:response) { { 'text' => 'transcribed text' } }

      it 'returns the transcribed text' do
        expect(client.transcribe('test_file')).to eq('transcribed text')
      end
    end

    context 'when unsuccessful' do
      let(:response) { { 'error' => 'transcribe error' } }

      it 'returns an error message' do
        expect(client.transcribe('test_file')).to eq 'Error: transcribe error'
      end
    end
  end
end
