require_relative '../opal_rspec_spec_loader'

module Opal
  module RSpec
    module SupportSpecLoader
      include Opal::RSpec::OpalRSpecSpecLoader

      extend self

      def expected_pending_count
        0
      end

      def base_dir
        'spec-opal-rspec/rspec/support'
      end

      def default_path
        'rspec-support/spec'
      end

      def spec_glob
        %w{rspec-support/spec/**/*_spec.rb}
      end

      def stubbed_requires
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
