require 'spec_helper'
require 'rspec/opal_rspec_spec_loader'

RSpec.describe 'RSpec specs:' do

  def expect_results_to_be(expected_results)
    results = run_specs
    failures = results.json[:examples].select { |ex| ex[:status] == 'failed' }
    print_results(results) unless failures.empty?

    expect(results.json[:summary_line]).to eq(expected_results)
    expect(failures).to eq([])
    expect(results).to be_successful
  rescue => e
    print_results(results)
    raise e
  end

  def print_results(results)
    return if results.nil?
    puts "=========== Output of failed run ============"
    puts results.quoted_output
    puts "============================================="
  end

  def spec_glob
    ["rspec-#{short_name}/spec/**/*_spec.rb",]
  end

  context 'Core' do
    include Opal::RSpec::OpalRSpecSpecLoader
    let(:short_name) { 'core' }

    it 'runs correctly' do
      expect_results_to_be('976 examples, 0 failures, 186 pending')
    end
  end

  context 'Support' do
    include Opal::RSpec::OpalRSpecSpecLoader
    let(:short_name) { 'support' }

    it 'runs correctly' do
      expect_results_to_be('66 examples, 0 failures, 14 pending')
    end
  end

  context 'Expectations' do
    include Opal::RSpec::OpalRSpecSpecLoader
    let(:short_name) { 'expectations' }

    it 'runs correctly' do
      expect_results_to_be('65 examples, 0 failures, 13 pending')
    end
  end

  context 'Mocks' do
    include Opal::RSpec::OpalRSpecSpecLoader
    let(:short_name) { 'mocks' }

    it 'runs correctly' do
      expect_results_to_be('1306 examples, 0 failures, 102 pending')
    end
  end
end
