require 'fileutils'

module Opal
  module RSpec
    # @private
    # Generates conventional files for an rspec project
    class ProjectInitializer
      attr_reader :destination, :stream, :template_path

      DOT_RSPEC_FILE = '.rspec-opal'
      SPEC_HELPER_FILE =  'spec-opal/spec_helper.rb'

      def initialize(opts={})
        @destination = opts.fetch(:destination, Dir.getwd)
        @stream = opts.fetch(:report_stream, $stdout)
        @template_path = opts.fetch(:template_path) do
          File.expand_path("../project_initializer", __FILE__)
        end
      end

      def run
        puts <<~EOF
          ** Do note, that Opal-RSpec defaults to the following paths:
          ** - config file:    .rspec-opal
          ** - spec directory: spec-opal
          ** - program:        lib-opal
          **
          ** If you want to share Opal specs with Ruby specs, you will
          ** need to put the following into your .rspec-opal:
          **
          ** -Ilib --default-path=spec
        EOF
        copy_template DOT_RSPEC_FILE
        copy_template SPEC_HELPER_FILE
      end

    private

      def copy_template(file)
        destination_file = File.join(destination, file)
        return report_exists(file) if File.exist?(destination_file)

        report_creating(file)
        FileUtils.mkdir_p(File.dirname(destination_file))
        File.open(destination_file, 'w') do |f|
          f.write File.read(File.join(template_path, file))
        end
      end

      def report_exists(file)
        stream.puts "   exist   #{file}"
      end

      def report_creating(file)
        stream.puts "  create   #{file}"
      end
    end
  end
end
