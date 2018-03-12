require 'spec_helper'
require 'rspec/opal_rspec_spec_loader'

RSpec.describe 'RSpec specs:' do

  def expect_results_to_be(expected_results)
    results = run_specs
    failures = results.json[:examples].select { |ex| ex[:status] == 'failed' }

    unless failures.empty?
      puts "=========== Output of failed run ============"
      puts results.quoted_output
      puts "============================================="
    end

    expect(results.json[:summary_line]).to eq(expected_results)
    expect(failures).to eq([])
    expect(results).to be_successful
  end

  def spec_glob
    ["rspec-#{short_name}/spec/**/*_spec.rb",]
  end

  def stubbed_requires
    [
      'rubygems',
      'aruba/api', # Cucumber lib that supports file creation during testing, N/A for us
      'simplecov', # hooks aren't available on Opal
      'tmpdir',
      'rspec/support/spec/shell_out', # only does stuff Opal can't support anyways
      'rspec/support/spec/prevent_load_time_warnings',
      'timeout',
    ]
  end

  def additional_load_paths
    [
      # 'rspec-core/spec' # a few spec support files live outside of rspec-core/spec/rspec and live in support
      # "#{__dir__}../../../lib-opal-spec-support",
      "lib-opal-spec-support",
    ]
  end


  context 'Core' do
    include Opal::RSpec::OpalRSpecSpecLoader
    let(:short_name) { 'core' }

    it 'runs correctly' do
      expect_results_to_be("727 examples, 0 failures, 111 pending")
    end
  end

  context 'Support' do
    include Opal::RSpec::OpalRSpecSpecLoader
    let(:short_name) { 'support' }

    it 'runs correctly' do
      expect_results_to_be("66 examples, 0 failures, 14 pending")
    end
  end

  context 'Expectations' do
    include Opal::RSpec::OpalRSpecSpecLoader
    let(:short_name) { 'expectations' }

    it 'runs correctly' do
      expect_results_to_be("65 examples, 0 failures, 13 pending")
    end
  end

end
