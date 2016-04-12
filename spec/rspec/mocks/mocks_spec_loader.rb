require_relative '../opal_rspec_spec_loader'

module Opal
  module RSpec
    module MocksSpecLoader
      extend Opal::RSpec::OpalRSpecSpecLoader

      def self.expected_pending_count
        11
      end

      def self.base_dir
        'spec/rspec/mocks'
      end

      def self.files_with_line_continue
        []
      end

      def self.default_path
        'rspec-mocks/spec'
      end

      def self.spec_glob
        %w{rspec-mocks/spec/**/*_spec.rb}
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
            /stubbed_message_expectations_spec.rb/,
            /stub_spec.rb/,
            /receive_spec.rb/,
            /hash_excluding_matcher_spec.rb/,
            /hash_including_matcher_spec.rb/,
            /\/double_spec.rb/,
            /argument_matchers_spec.rb/
        ]
      end

      def self.symbols_replace_regexes
        [
            /(expect.*description\)\.to eq)\((.*)\)/,
            /(expect.*description\)\.to eq) (.*)/,
            /(raise_error)\((%Q.*)\)/,
            /(raise_error)\((\/received (?!:two).*\/.*)\)/,
            /(raise_error\(RSpec::Mocks::MockExpectationError,) (.*\))/,
            /(fail_\w+)\((\/expected: \\\({\(:.*)\)/,
            # "expected: (hash_not_including(:a=>1))"
            /(fail_\w+) ("expected: \(hash.*)/,
            # fail_matching "expected: (duck_type(:abs, :div))"
            /(fail_\w+) ("expected: \(duck_type.*)/
        ]
      end

      def self.symbol_do_not_replace_regexes
        # in these cases, the symbols do come in correctly in Opal
        [
            # fails when args are expected but none are received
            'raise_error(RSpec::Mocks::MockExpectationError, %q|Double "test double" received unexpected message :foobar with (no args)|)',
            # fails if unexpected method called
            'raise_error(RSpec::Mocks::MockExpectationError, "Double \"test double\" received unexpected message :something with (\"a\", \"b\", \"c\")")'
        ].map { |r| Regexp.new(Regexp.escape(r)) }
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
