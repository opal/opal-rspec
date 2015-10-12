require_relative '../opal_rspec_spec_loader'

module Opal
  module RSpec
    module MocksSpecLoader
      extend Opal::RSpec::OpalRSpecSpecLoader

      def self.expected_pending_count
        10
      end

      def self.base_dir
        'spec/rspec/mocks'
      end

      def self.files_with_line_continue
        []
      end

      def self.spec_directories
        # will have a glob appended to each element in the array
        %w{rspec-mocks/spec}
      end

      def self.stubbed_requires
        [
            'rubygems',
            'rspec/support/spec/shell_out', # only does stuff Opal can't support anyways,
            'spec', # we have our own version of this in spec_helper that's compatible
            'simplecov', # hooks aren't available on Opal
            'yaml', # not avail om opal yet
            'psych',
            'support/doubled_classes', # we have to create our own version of this due to eval in their code
            'spec_helper' # we include our own spec helper that's opal compatible (spec_helper_opal)
        ]
      end

      def self.symbol_files
        [
            /have_received_spec.rb/,
            /stubbed_message_expectations_spec.rb/
        ]
      end

      def self.symbols_replace_regexes
        [
            /(expect.*description\)\.to eq)\((.*)\)/,
            /(expect.*description\)\.to eq) (.*)/,
            /(raise_error)\((%Q.*)\)/
        ]
      end

      def self.sub_in_files
        files = super
        symbols_in_expectations files
      end

      def self.additional_load_paths
        [
            'rspec-mocks/spec' # a few spec support files live outside of rspec-mocks/spec/rspec and live in support
        ]
      end
    end
  end
end
