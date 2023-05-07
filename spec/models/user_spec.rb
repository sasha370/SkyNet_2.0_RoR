# frozen_string_literal: true

RSpec.describe User do
  describe 'associations' do
    it { is_expected.to have_many(:events).dependent(:destroy) }
  end

  # describe 'validations' do
  #   it { is_expected.to validate_presence_of(:telegram_id) }
  #   it { is_expected.to validate_uniqueness_of(:telegram_id) }
  # end
end
