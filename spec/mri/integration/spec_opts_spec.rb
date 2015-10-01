require 'rspec'

describe 'spec_opts' do
  subject { `SPEC_OPTS="#{spec_opts}" rake other_specs` }

  RSpec.shared_context :color_test do |expected_pass|
    it {
      matcher = match Regexp.new Regexp.escape("\e[32m1 example, 0 failures\e[0m")
      exp = is_expected
      expected_pass ? exp.to(matcher) : exp.to_not(matcher)
    }
  end

  context 'color set' do
    let(:spec_opts) { '--colors' }

    include_context :color_test, true
  end

  context 'empty' do
    let(:spec_opts) { '' }

    it { is_expected.to match /1 example, 0 failures/ }

    include_context :color_test, false
  end

  context 'nothing set' do
    subject { `rake other_specs` }

    it { is_expected.to match /1 example, 0 failures/ }

    include_context :color_test, false
  end
end
