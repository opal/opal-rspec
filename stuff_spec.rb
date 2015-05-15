require 'rspec'

describe true do
  subject {true}
  it { is_expected.to equal true }
end