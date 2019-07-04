require 'spec_helper'

RSpec.describe 'RSpec specs:' do

  def expect_results_to_be(expected_summary)
    runner = Opal::RSpec::UpstreamTests::Runner.new
    results = runner.run
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
    puts "~~~ #{results.command} ~~~"
    puts "=========== Output of failed run ============"
    puts results.quoted_output
    puts "============================================="
  end

  context 'Core' do
    it 'runs correctly', gem_name: 'rspec-core' do
      expect_results_to_be('976 examples, 0 failures, 188 pending')
    end
  end

  context 'Support' do
    it 'runs correctly', gem_name: 'rspec-support' do
      expect_results_to_be('66 examples, 0 failures, 14 pending')
    end
  end

  context 'Expectations' do
    it 'runs correctly', gem_name: 'rspec-expectations' do
      expect_results_to_be('1775 examples, 0 failures, 174 pending')
    end
  end

  context 'Mocks' do
    it 'runs correctly', gem_name: 'rspec-mocks' do
      expect_results_to_be('1306 examples, 0 failures, 102 pending')
    end
  end
end
