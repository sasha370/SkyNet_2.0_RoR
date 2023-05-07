# frozen_string_literal: true

RSpec.describe Handlers::UnknownTypeHandler do
  let(:handle_event) { described_class.process(event) }

  let(:event) { create(:event, :with_unknown_type) }

  describe 'when Event type is unknown' do
    it 'returns answer with text' do
      handle_event
      expect(event.answer.text).to eq(I18n.t('event_handler.unsupported_event'))
    end
  end
end
