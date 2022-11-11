require 'spec_helper'
require 'json'

RSpec.describe 'spec_opts' do
  let(:rake_task) { 'other_specs' }
  subject(:output) { `SPEC_OPTS="#{spec_opts}" rake #{rake_task}` }

  RSpec.shared_context :color_test do |expected_pass|
    it {
      matcher = match Regexp.new Regexp.escape("\e[32m1 example, 0 failures\e[0m")
      exp = is_expected
      expected_pass ? exp.to(matcher) : exp.to_not(matcher)
    }
  end

  context 'color set' do
    let(:spec_opts) { '--color' }

    include_context :color_test, true
  end

  context 'no color explicitly set' do
    let(:spec_opts) { '--no-color' }
    let(:rake_task) { 'color_on_by_default' }

    it { is_expected.to match /1 example, 0 failures/ }

    include_context :color_test, false
  end

  context 'formatter set' do
    let(:spec_opts) { '--format json' }
    let(:expected_json_hash) do
      {
          'examples' =>
              [
                  {
                      'description' => 'is expected to eq 42',
                      'full_description' => 'foobar is expected to eq 42',
                      'status' => 'passed',
                      'file_path' => be_a(String),
                      'id' => be_a(String),
                      'line_number' => be_a(Integer),
                      'run_time' => be_a(Float),
                      'pending_message' => nil,
                  }    
              ],
          'summary' => {
              'duration' => be_a(Float),
              'errors_outside_of_examples_count' => 0,
              'example_count' => 1,
              'failure_count' => 0,
              'pending_count' => 0
          },
          'summary_line' => '1 example, 0 failures',
          'version' => be_a(String)
      }
    end

    subject { JSON.parse(/(\{.*)/.match(output).captures[0]) }

    it { is_expected.to include expected_json_hash }
  end

  context 'empty' do
    let(:spec_opts) { '' }

    it { is_expected.to match /1 example, 0 failures/ }

    include_context :color_test, true
  end

  context 'requires and format' do
    let(:spec_opts) { '--format TestFormatter --require formatter_dependency --require test_formatter' }

    xit { is_expected.to match /{"examples".*test formatter ran!/m }
  end

  context 'default' do
    subject { `rake other_specs` }

    it { is_expected.to match /1 example, 0 failures/ }

    include_context :color_test, true
  end
end
