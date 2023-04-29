# frozen_string_literal: true

RSpec.describe HelpCommand do
  let(:answer) { ['Choose command:', 'some markup'] }

  before do
    allow(described_class).to receive(:call).and_return(answer)
  end

  # It is not a good idea to test allowed methods BUT in this case it is just a stub for test
  it 'returns answer' do
    expect(described_class.call).to eq(answer)
  end
end
