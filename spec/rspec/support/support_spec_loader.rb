require_relative '../opal_rspec_spec_loader'

module Opal
  module RSpec
    module SupportSpecLoader
      extend Opal::RSpec::OpalRSpecSpecLoader

      def self.expected_pending_count
        0
      end

      def self.base_dir
        'spec/rspec/support'
      end

      def self.files_with_line_continue
        [/support\/method_signature_verifier_spec.rb/]
      end

      def self.default_path
        'rspec-support/spec'
      end

      def self.spec_glob
        %w{rspec-support/spec/**/*_spec.rb}
      end

      def self.stubbed_requires
        [
            'rubygems',
            'rspec/support/spec/shell_out', # only does stuff Opal can't support anyways,
            'spec', # we have our own version of this in spec_helper that's compatible
            'simplecov', # hooks aren't available on Opal
        ]
      end
    end
  end
end
