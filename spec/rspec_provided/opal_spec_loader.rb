require 'tmpdir'

module Opal
  module RSpec
    class OpalSpecLoader
      FILES_WITH_LINE_CONTINUE = [/core\/example_spec.rb/, /pending_spec.rb/]
      # will have a glob appended to each element in the array
      SPEC_DIRECTORIES = %w{rspec-core/spec spec/rspec_provided/opal_alternates}
      REQUIRE_STUBS = [
          'rubygems',
          'aruba/api', # Cucumber lib that supports file creation during testing, N/A for us
          'simplecov', # hooks aren't available on Opal
          'tmpdir',
          'rspec/support/spec/shell_out', # only does stuff Opal can't support anyways
          'rspec/support/spec/prevent_load_time_warnings'
        ]

      def self.stub_requires
        REQUIRE_STUBS.each {|f| Opal::Processor.stub_file f}
      end

      def self.get_ignored_spec_failures
        FileList['spec/rspec_provided/filter/**/*.txt'].map do |filename|
          get_exclusions_compact filename
        end.flatten
      end

      def self.get_exclusions_compact(filename)
        line_num = 0
        File.read(filename).split("\n").map do |line|
          line_num += 1
          {
            exclusion: line,
            line_number: line_num
          }
        end.reject do |line|
          exclusion = line[:exclusion]
          exclusion.empty? or exclusion.start_with? '#'
        end
      end

      def self.get_file_list
        exclude_these_specs = get_exclusions_compact 'spec/rspec_provided/spec_files_exclude.txt'
        missing_exclusions = exclude_these_specs.map do |f|
          result = SPEC_DIRECTORIES.any? do |spec_dir|
            FileList[File.join(spec_dir, f[:exclusion])].any?
          end
          result ? nil : f
        end.compact
        if missing_exclusions.any?
          raise "Expected to exclude #{missing_exclusions} as noted in spec_files_exclude.txt but we didn't find these files. Has RSpec been upgraded?"
        end
        exclude_globs_only = exclude_these_specs.map {|f| f[:exclusion]}
        include_globs = SPEC_DIRECTORIES.map {|g| File.join(g, '**/*_spec.rb')}
        files = FileList[
          'spec/rspec_provided/rspec_spec_fixes.rb', # need our code to go in first
          *include_globs
        ].exclude(*exclude_globs_only)
        puts "Running the following RSpec specs:"
        files.sort.each {|f| puts f}
        files
      end

      def self.append_additional_load_paths(server)
        [
          'rspec-core/spec' # a few spec support files live outside of rspec-core/spec/rspec and live in support
        ].each {|p| server.append_path p}
      end

      # https://github.com/opal/opal/issues/821
      def self.sub_in_end_of_line(files)
        bad_regex = /^(.*)\\$/
        fix_these_files = files.select {|f| FILES_WITH_LINE_CONTINUE.any? {|regex| regex.match(f)}}
        dir = Dir.mktmpdir
        missing = []
        fixed_temp_files = fix_these_files.map do |path|
          temp_filename = File.join dir, File.basename(path)
          found_blackslash = false
          File.open path, 'r' do |input_file|
            File.open temp_filename, 'w' do |output_file|
              last_line_has_slash = false
              fixed_lines = input_file.inject do |line1, line2|
                existing_lines = [*line1]
                if (a_match = bad_regex.match existing_lines.last)
                  found_blackslash = true
                  line_num = existing_lines.length
                  puts "Replacing trailing backlash, line #{line_num} in #{path} in new temp file #{temp_filename}"
                  without_last_line = existing_lines[0..-2]
                  without_backlash = a_match.captures[0]
                  without_last_line << (without_backlash + ' ' + line2)
                else
                  existing_lines << line2
                end
              end
              fixed_lines.each {|l| output_file << l}
            end
          end
          missing << path unless found_blackslash
          temp_filename
        end
        at_exit do
          FileUtils.remove_entry dir
        end
        raise "Expected to fix blackslash continuation in #{fix_these_files} but we didn't find any backslashes in #{missing}. Check if RSpec has been upgraded (maybe those blackslashes are gone??)" if missing.any?
        files_we_left_alone = files - fix_these_files
        files_we_left_alone + fixed_temp_files
      end
    end
  end
end
