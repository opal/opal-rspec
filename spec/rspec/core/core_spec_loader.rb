require_relative '../opal_spec_loader'

module Opal
  module RSpec
    module CoreSpecLoader
      extend Opal::RSpec::OpalSpecLoader

      def self.expected_pending_count
        1
      end

      def self.base_dir
        'spec/rspec/core'
      end

      def self.files_with_line_continue
        [/core\/example_spec.rb/, /pending_spec.rb/]
      end

      def self.spec_directories
        # will have a glob appended to each element in the array
        %w{rspec-core/spec spec/rspec/core/opal_alternates}
      end

      def self.stubbed_requires
        [
            'rubygems',
            'aruba/api', # Cucumber lib that supports file creation during testing, N/A for us
            'simplecov', # hooks aren't available on Opal
            'tmpdir',
            'rspec/support/spec/shell_out', # only does stuff Opal can't support anyways
            'rspec/support/spec/prevent_load_time_warnings'
        ]
      end

      def self.additional_load_paths
        [
            'rspec-core/spec' # a few spec support files live outside of rspec-core/spec/rspec and live in support
        ]
      end
    end
  end
end
