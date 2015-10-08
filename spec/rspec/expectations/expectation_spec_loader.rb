require_relative '../opal_rspec_spec_loader'

module Opal
  module RSpec
    module ExpectationSpecLoader
      extend Opal::RSpec::OpalRSpecSpecLoader

      def self.expected_pending_count
        0
      end

      def self.base_dir
        'spec/rspec/expectations'
      end

      def self.spec_directories
        # will have a glob appended to each element in the array
        %w{rspec-expectations/spec spec/rspec/expectations/opal_alternates}
      end

      def self.files_with_line_continue
        [/matchers\/dsl_spec.rb/]
      end

      def self.files_with_multiline_regex
        [/matchers\/built_in\/match_spec.rb/]
      end

      def self.post_requires
        %w{fixes/example_patches.rb}
      end

      def self.sub_in_files
        files = super
        symbols_in_expectations files
      end

      def self.symbols_in_expectations(files)
        # fail_with(/expected .* to respond to :some_method/)
        replace_with_regex /fail_with\((.*)\)/, 'fix symbols in message expectations', files, [/respond_to_spec.rb/] do |match, temp_filename|
          # Don't want to match #<Object:.*>
          fail_with_wo_symbols = match.captures[0].gsub(/:([a-zA-Z]\w*)/, "\"\\1\"")
          new = "fail_with(#{fail_with_wo_symbols})"
          puts "Replacing #{match.to_s} with #{new} in new temp file #{temp_filename}"
          new
        end
      end

      def self.stubbed_requires
        [
            'timeout', # not part of opal stdlib
            'rubygems',
            'simplecov', # hooks aren't available on Opal
            'open3', # File I/O
            'rake/file_utils', # Rake not around
            'complex', # not part of opal stdlib
            'rspec/support/spec/shell_out', # only does stuff Opal can't support anyways
            'bigdecimal',
        # 'aruba/api', # Cucumber lib that supports file creation during testing, N/A for us
        # 'tmpdir',
        # 'rspec/support/spec/shell_out', # only does stuff Opal can't support anyways
        # 'rspec/support/spec/prevent_load_time_warnings'
        ]
      end

      def self.additional_load_paths
        [
            'rspec-expectations/spec' # a few spec support files live outside of rspec-expectations/spec/rspec and live in support
        ]
      end
    end
  end
end
