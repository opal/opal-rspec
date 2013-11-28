require 'opal'
require 'opal/rspec/version'

module Opal
  module RSpec
    extend self

    def base_dir
      File.expand_path('../../..', __FILE__)
    end

    def build_rspec_js force = false
      path = File.expand_path('../../../opal/opal/rspec/rspec.js', __FILE__)
      puts "Building: #{path}..."
      return if File.exist? path and not(force)
      File.open(path, 'w+') { |out| out << rspec_js_code }
    end

    def rspec_js_code
      previous_severity = Opal::Processor.dynamic_require_severity
      Opal::Processor.dynamic_require_severity = :warning
      Opal.append_path File.join(base_dir, 'app')

      Opal.use_gem 'rspec'
      Opal.use_gem 'rspec-expectations'

      %w[time fileutils test/unit/assertions coderay optparse shellwords socket uri
         drb/drb diff/lcs diff/lcs/hunk].each do |asset|
        Opal::Processor.stub_file asset
      end

      # bug in rspec? this autoload doesnt exist so we must stub it
      Opal::Processor.stub_file 'rspec/matchers/built_in/have'

      Opal.process('rspec-builder').tap do
        Opal::Processor.dynamic_require_severity = previous_severity
      end
    end
  end
end

# Just register our opal code path with opal build tools
Opal.append_path File.join(Opal::RSpec.base_dir, 'opal')

