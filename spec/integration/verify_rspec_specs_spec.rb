require 'spec_helper'

RSpec.describe 'RSpec specs:' do

  def expect_results_to_be(expected_summary)
    results = Opal::RSpec::UpstreamTests::Runner.new.run
    failures = results.json[:examples].select { |ex| ex[:status] == 'failed' }
    print_results(results) unless failures.empty?

    expect(results.json[:summary_line]).to eq(expected_summary)
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

  context 'Core' do
    it 'runs correctly', gem_name: 'rspec-core' do
      expect_results_to_be('1622 examples, 0 failures, 391 pending')
    end
  end

  context 'Support' do
    it 'runs correctly', gem_name: 'rspec-support' do
      expect_results_to_be('181 examples, 0 failures, 32 pending')
    end
  end

  context 'Expectations' do
    it 'runs correctly', gem_name: 'rspec-expectations' do
      expect_results_to_be('1798 examples, 0 failures, 362 pending')
    end
  end

  context 'Mocks' do
    # There are errors outside of examples which can't be filtered.
    # Let's keep it skipped for now.
    xit 'runs correctly', gem_name: 'rspec-mocks' do
      expect_results_to_be('1683 examples, 9 failures, 485 pending')
    end
  end

  context 'Diff-LCS' do
    it 'runs correctly', gem_name: 'diff-lcs' do
      expect_results_to_be('272 examples, 0 failures')
    end
  end
end
