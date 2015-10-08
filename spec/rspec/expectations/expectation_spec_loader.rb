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
        files = symbols_in_expectations files
        files = integer_decimals files
        anonymous_examples_operators files
      end

      def self.symbol_files
        [
            /respond_to_spec.rb/,
            /include_spec.rb/,
            /have_attributes_spec.rb/,
            /has_spec.rb/,
            /raise_error_spec.rb/
        ]
      end

      def self.integer_float_files
        [/be_within_spec.rb/]
      end

      def self.anonymous_examples_operators(files)
        example_number = 0
        replace_with_regex /specify do(.*?)end/m, 'anonymous examples we cannot filter', files, [/aliases_spec.rb/] do |match, temp_filename|
          example_number += 1
          body = match.captures[0]
          contains_operator = /a_value [<>]/.match(body) || /a_value <=/.match(body)
          next match.to_s unless contains_operator
          fixed = "specify 'alias example #{example_number}' do\n#{body}\nend"
          puts "#{temp_filename} - anonymous examples we cannot filter - replacing #{match.to_s} with #{fixed}"
          fixed
        end
      end

      def self.integer_decimals(files)
        matching_exp = [
            /fail_\w+\((.*)\)/,
            /expect.*description\)\.to eq (.*)/
        ]
        # In Opal, 5.0 will be considered 5. Rather than muck with all of the code, any time we're expecting 5.0, just change it to 5
        replace_with_regex matching_exp, 'expected integers when given integers', files, integer_float_files do |match, temp_filename|
          integer_regex = /(\d+)\.0/
          has_integers = integer_regex.match(match.captures[0])
          next match.to_s unless has_integers
          fixed = match.to_s.gsub(integer_regex, "\\1")
          puts "#{temp_filename} - float/integer fix, replacing #{match.to_s} with #{fixed} in new temp file"
          fixed
        end
      end

      def self.symbols_in_expectations(files)
        matching = [
            /(fail_\w+)\((.*)\)/,
            /(expect.*description\)\.to eq)\((.*)\)/
        ]
        # fail_with(/expected .* to respond to :some_method/)
        replace_with_regex matching, 'fix symbols in message expectations', files, symbol_files do |match, temp_filename|
          # Don't want to match #<Object:.*>
          between_parens = match.captures[1]
          symbol_matcher = /:([a-zA-Z]\w*)/
          next match.to_s unless symbol_matcher.match(between_parens)
          # Escape quotes if in a string
          replace_pattern = if between_parens.start_with? '"'
                              "\\\"\\1\\\""
                            else
                              "\"\\1\""
                            end
          fail_with_wo_symbols = between_parens.gsub(symbol_matcher, replace_pattern)
          fail_type = match.captures[0]
          new = "#{fail_type}(#{fail_with_wo_symbols})"
          puts "#{temp_filename} - symbol fix -replacing #{match.to_s} with #{new} in new temp file"
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
