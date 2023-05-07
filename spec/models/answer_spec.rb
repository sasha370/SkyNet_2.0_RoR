# frozen_string_literal: true

RSpec.describe Answer do
  describe 'associations' do
    it { is_expected.to belong_to(:event) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:chat_id) }
  end
end
