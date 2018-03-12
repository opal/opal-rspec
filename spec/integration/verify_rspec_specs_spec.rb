require 'spec_helper'
require 'rspec/opal_rspec_spec_loader'

RSpec.describe 'RSpec' do
  context 'Core' do
    include Opal::RSpec::OpalRSpecSpecLoader

    def expected_pending_count
      1
    end

    def short_name
      'core'
    end

    def base_dir
      'spec/rspec/core'
    end

    def files_with_line_continue
      [
        /core\/example_spec.rb/,
        /pending_spec.rb/,
      ]
    end

    def default_path
      'rspec-core/spec'
    end

    def spec_glob
      [
        # 'rspec-core/spec/rspec/core/backtrace_formatter_spec.rb',
        'rspec-core/spec/rspec/core/configuration_options_spec.rb',
        'rspec-core/spec/rspec/core/configuration_spec.rb',
        'rspec-core/spec/rspec/core/drb_spec.rb',
        'rspec-core/spec/rspec/core/dsl_spec.rb',
        'rspec-core/spec/rspec/core/example_execution_result_spec.rb',
        'rspec-core/spec/rspec/core/example_group_constants_spec.rb',
        'rspec-core/spec/rspec/core/example_group_spec.rb',
        'rspec-core/spec/rspec/core/example_spec.rb',
        'rspec-core/spec/rspec/core/failed_example_notification_spec.rb',
        'rspec-core/spec/rspec/core/filter_manager_spec.rb',

        'rspec-core/spec/rspec/core/formatters/base_text_formatter_spec.rb',
        'rspec-core/spec/rspec/core/formatters/console_codes_spec.rb',
        'rspec-core/spec/rspec/core/formatters/deprecation_formatter_spec.rb',

        # 'rspec-core/spec/rspec/core/formatters/documentation_formatter_spec.rb',
        # 'rspec-core/spec/rspec/core/formatters/helpers_spec.rb',
        # 'rspec-core/spec/rspec/core/formatters/html_formatter_spec.rb',
        # 'rspec-core/spec/rspec/core/formatters/json_formatter_spec.rb',
        # 'rspec-core/spec/rspec/core/formatters/profile_formatter_spec.rb',
        # 'rspec-core/spec/rspec/core/formatters/progress_formatter_spec.rb',
        # 'rspec-core/spec/rspec/core/formatters/snippet_extractor_spec.rb',

        # 'rspec-core/spec/rspec/core/formatters_spec.rb',
        # 'rspec-core/spec/rspec/core/hooks_filtering_spec.rb',
        # 'rspec-core/spec/rspec/core/hooks_spec.rb',
        # 'rspec-core/spec/rspec/core/memoized_helpers_spec.rb',
        # 'rspec-core/spec/rspec/core/metadata_filter_spec.rb',
        # 'rspec-core/spec/rspec/core/metadata_spec.rb',
        'rspec-core/spec/rspec/core/notifications_spec.rb',
        # 'rspec-core/spec/rspec/core/option_parser_spec.rb',
        # 'rspec-core/spec/rspec/core/ordering_spec.rb',
        # 'rspec-core/spec/rspec/core/pending_example_spec.rb',
        # 'rspec-core/spec/rspec/core/pending_spec.rb',
        # 'rspec-core/spec/rspec/core/project_initializer_spec.rb',
        # 'rspec-core/spec/rspec/core/rake_task_spec.rb',
        # 'rspec-core/spec/rspec/core/random_spec.rb',
        # 'rspec-core/spec/rspec/core/reporter_spec.rb',

        # 'rspec-core/spec/rspec/core/rspec_matchers_spec.rb',
        # 'rspec-core/spec/rspec/core/ruby_project_spec.rb',
        # 'rspec-core/spec/rspec/core/runner_spec.rb',
        # 'rspec-core/spec/rspec/core/shared_context_spec.rb',
        # 'rspec-core/spec/rspec/core/shared_example_group_spec.rb',
        # 'rspec-core/spec/rspec/core/warnings_spec.rb',
        # 'rspec-core/spec/rspec/core/world_spec.rb',

        # 'rspec-core/spec/**/*_spec.rb',
        # 'spec/rspec/core/opal_alternates/**/*_spec.rb',
      ]
    end

    def stubbed_requires
      [
        'rubygems',
        'aruba/api', # Cucumber lib that supports file creation during testing, N/A for us
        'simplecov', # hooks aren't available on Opal
        'tmpdir',
        'rspec/support/spec/shell_out', # only does stuff Opal can't support anyways
        'rspec/support/spec/prevent_load_time_warnings'
      ]
    end

    def additional_load_paths
      [
        # 'rspec-core/spec' # a few spec support files live outside of rspec-core/spec/rspec and live in support
        # "#{__dir__}../../../lib-opal-spec-support",
        "lib-opal-spec-support",
      ]
    end

    it 'has specs run correctly' do
      results = run_specs
      expect(results.success).to eq(true)



      # puts results[:example_info]
      parsed_results    = parse_results results
      next
      summary           = parsed_results['summary']
      total             = summary['example_count']
      failed            = summary['failure_count']
      pending           = summary['pending_count']
      actual_failures   = parsed_results['examples'].select { |ex| ex['status'] == 'failed' }
      expected_failures = get_ignored_spec_failures
      used_exclusions   = []

      remaining_failures = actual_failures.reject do |actual|
        expected_failures.any? do |expected|
          exclusion = expected[:exclusion]
          actual_descr = actual['full_description']
          matches = case exclusion
                    when Regexp then exclusion.match actual_descr
                    when String then exclusion == actual_descr
                    else raise "Unknown filter expression type #{exclusion.class} in #{expected}!"
                    end
          used_exclusions << expected if matches
          matches
        end
      end
      each_header = '----------------------------------------------------'
      index = 0
      remaining_failures = remaining_failures.map do |example|
        index += 1
        [
          each_header,
          "Example #{index}: #{example['full_description']}",
          each_header,
          example['exception']['message']
        ].join "\n"
      end
      reasons = []
      reasons << 'Unexpected failures' unless remaining_failures.empty?
      reasons << "Expected #{expected_pending_count} pending but got #{pending}" unless pending == expected_pending_count
      reasons << 'no specs found' unless total > 0
      reasons << 'No failures, but Rake task did not succeed' if (failed == 0 && !results[:success])
      unused_exclusions = expected_failures.uniq - used_exclusions.uniq
      if unused_exclusions.any?
        msg = "WARNING: The following #{unused_exclusions.length} exclusion rules did not match an actual failure. Time to update exclusions? Duplicate exclusions??\n" +
            unused_exclusions.map { |e| "File: #{e[:filename]}\nLine #{e[:line_number]}\nFilter: #{e[:exclusion]}" }.join("\n---------------------\n")
        reasons << msg
      end
      passing = total - failed - pending
      percentage = ((passing.to_f / total) * 100).round(1)
      if reasons.empty?
        puts 'Test successful!'
        puts "#{total} total specs, #{failed} expected failures, #{pending} expected pending"
        puts "Passing percentage: #{percentage}%"
      else
        puts "Test FAILED for the following reasons:\n"
        puts reasons.join "\n\n"
        if remaining_failures.any?
          puts
          puts "Unexpected failures:\n\n#{remaining_failures.join("\n")}\n"
        end
        puts '-----------Summary-----------'
        puts "Total passed count: #{passing}"
        puts "Pending count #{pending}"
        puts "Total 'failure' count: #{actual_failures.length}"
        puts "Passing percentage: #{percentage}%"
        puts "Unexpected failure count: #{remaining_failures.length}"
        raise 'Test failed!'
      end
    end
  end
end
