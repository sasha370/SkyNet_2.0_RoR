# frozen_string_literal: true

RSpec.describe Event do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:event_type) }
    it { is_expected.to validate_presence_of(:chat_id) }
    it { is_expected.to validate_presence_of(:data) }
  end
end
