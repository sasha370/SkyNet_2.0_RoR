# frozen_string_literal: true

RSpec.describe Handlers::CallbackHandler do
  describe '#call' do
    let(:event_data) { {} }
    let(:event) { create(:event, :with_callback, data: event_data) }
    let(:callback_handler) { described_class.new(event) }

    shared_examples 'a valid callback message' do |data, message|
      let(:event_data) { { 'data' => data } }

      it "returns a valid message for #{data}" do
        expect(callback_handler.call).to eq(message)
      end
    end

    context "when data is 'how_it_works'" do
      it_behaves_like 'a valid callback message', 'how_it_works', I18n.t('callbacks.how_it_works_message')
    end

    context "when data is 'restrictions'" do
      it_behaves_like 'a valid callback message', 'restrictions', I18n.t('callbacks.restrictions_message')
    end

    context "when data is 'examples'" do
      it_behaves_like 'a valid callback message', 'examples', I18n.t('callbacks.examples_message')
    end

    context "when data is 'voice_button'" do
      it_behaves_like 'a valid callback message', 'voice_button', I18n.t('callbacks.voice_button_message')
    end

    context "when data is 'change_language'" do
      let(:event_data) { { 'data' => 'change_language' } }

      it 'changes the language to English if the current language is Russian' do
        I18n.with_locale(:ru) do
          callback_handler.call
          expect(I18n.locale).to eq(:en)
        end
      end

      it 'changes the language to Russian if the current language is English' do
        I18n.with_locale(:en) do
          callback_handler.call
          expect(I18n.locale).to eq(:ru)
        end
      end

      it 'returns a valid message' do
        expect(callback_handler.call).to eq(I18n.t('callbacks.language_changed_message'))
      end
    end

    context 'when data is unknown' do
      let(:event_data) { { 'data' => 'unknown_data' } }

      it 'returns a default message' do
        expect(callback_handler.call).to eq(I18n.t('callbacks.not_known_message'))
      end
    end
  end
end
