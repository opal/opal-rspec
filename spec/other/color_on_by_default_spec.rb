RSpec::configure do |c|
  c.color = true
end

describe 'colors' do
  subject { 42 }

  it { is_expected.to eq 42 }
end
