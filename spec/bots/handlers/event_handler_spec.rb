# frozen_string_literal: true

RSpec.describe Handlers::EventHandler do
  let(:handle_event) { described_class.process(event) }

  let(:answer) { 'I can hear you, don\'t scream!' }
  let(:event) { create(:event) }

  describe 'when the event is a Message' do
    before do
      allow(Handlers::MessageHandler).to receive(:process).and_return(answer)
    end

    it 'calls handler and return answer' do
      expect(Handlers::MessageHandler).to receive(:process).with(event)
      expect(handle_event).to eq([event.chat_id, answer, nil])
    end
  end

  describe 'when the event is a callback' do
    let(:event) { create(:event, :with_callback) }
    let(:callback_answer) { 'Here is my callback answer' }

    before do
      allow(Handlers::CallbackHandler).to receive(:process).and_return(callback_answer)
    end

    it 'calls handle_callback' do
      expect(Handlers::CallbackHandler).to receive(:process).with(event)
      expect(handle_event).to eq([event.chat_id, callback_answer])
    end
  end

  describe 'when the event is unsupported' do
    let(:answer) { I18n.t('event_handler.unsupported_event') }
    let(:event) { create(:event, :with_unknown_type) }

    it 'calls handle_callback' do
      expect(handle_event).to eq([event.chat_id, answer])
    end
  end
end
