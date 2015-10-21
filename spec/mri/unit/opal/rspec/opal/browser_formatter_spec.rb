describe Opal::RSpec::BrowserFormatter do
  context 'group' do
    it 'passes' do
      expect(42).to eq 42
    end

    xit 'a skipped example' do
    end

    it 'a failed example' do
      expect(42).to eq 43
    end
  end
end
