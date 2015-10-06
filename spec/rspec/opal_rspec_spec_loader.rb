require 'tmpdir'

module Opal
  module RSpec
    module OpalRSpecSpecLoader
      include Rake::DSL

      def files_with_line_continue
        []
      end

      def files_with_multiline_regex
        []
      end

      def unstub_requires
        []
      end

      def additional_load_paths
        []
      end

      def get_ignored_spec_failures
        FileList[File.join(base_dir, 'filter/**/*.txt')].map do |filename|
          get_exclusions_compact filename
        end.flatten
      end

      def stub_requires
        stubbed_requires.each { |f| Opal::Processor.stub_file f }
        unstub_requires.each do |f|
          puts "Unstubbing #{f} per test request"
          Opal::Processor.stubbed_files.delete f
        end
      end

      def get_file_list
        exclude_these_specs = get_exclusions_compact File.join(base_dir, 'spec_files_exclude.txt')
        missing_exclusions = exclude_these_specs.map do |f|
          result = spec_directories.any? do |spec_dir|
            FileList[File.join(spec_dir, f[:exclusion])].any?
          end
          result ? nil : f
        end.compact
        if missing_exclusions.any?
          raise "Expected to exclude #{missing_exclusions} as noted in spec_files_exclude.txt but we didn't find these files. Has RSpec been upgraded?"
        end
        exclude_globs_only = exclude_these_specs.map { |f| f[:exclusion] }
        include_globs = spec_directories.map { |g| File.join(g, '**/*_spec.rb') }
        files = FileList[
            File.join(base_dir, 'require_specs.rb'), # need our code to go in first
            *include_globs
        ].exclude(*exclude_globs_only)
        puts "Running the following RSpec specs:"
        files.sort.each { |f| puts f }
        files
      end

      def append_additional_load_paths(server)
        baseline = ['spec/rspec/shared']
        (baseline + additional_load_paths).each { |p| server.append_path p }
      end

      # https://github.com/opal/opal/issues/1125
      def remove_multiline_regexes(files)
        bad_regex = /(%r%$.*%)$/m
        fix_these_files = files.select { |f| files_with_multiline_regex.any? { |regex| regex.match(f) } }
        return files unless fix_these_files.any?
        dir = Dir.mktmpdir
        missing = []
        fixed_temp_files = fix_these_files.map do |path|
          temp_filename = File.join dir, File.basename(path)
          input = File.read path
          found_regex = false
          input.gsub!(bad_regex) do |_|
            found_regex = true
            multi_line_regex = Regexp
                                   .last_match
                                   .captures[0]
                                   .gsub("\n", '')
            parsed = instance_eval multi_line_regex # can just have ruby do this for us
            escaped = parsed
                          .source
                          .gsub('/', '\/')
            replace = "/#{escaped}/m"
            puts "Replacing multiline regex with #{replace} in new temp file #{temp_filename}"
            replace
          end
          File.open temp_filename, 'w' do |output_file|
            output_file.write input
          end
          missing << path unless found_regex
          temp_filename
        end
        at_exit do
          FileUtils.remove_entry dir
        end
        raise "Expected to fix multiline regex in #{fix_these_files} but we didn't find any expressions in #{missing}. Check if RSpec has been upgraded" if missing.any?
        files_we_left_alone = files - fix_these_files
        files_we_left_alone + fixed_temp_files
      end

      # https://github.com/opal/opal/issues/821
      def sub_in_end_of_line(files)
        bad_regex = /^(.*)\\$/
        fix_these_files = files.select { |f| files_with_line_continue.any? { |regex| regex.match(f) } }
        return files unless fix_these_files.any?
        dir = Dir.mktmpdir
        missing = []
        fixed_temp_files = fix_these_files.map do |path|
          temp_filename = File.join dir, File.basename(path)
          found_blackslash = false
          File.open path, 'r' do |input_file|
            File.open temp_filename, 'w' do |output_file|
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
              fixed_lines.each { |l| output_file << l }
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

      def execute_specs(name)
        command_line = "SPEC_OPTS=\"--format Opal::RSpec::ProgressJsonFormatter\" rake #{name}"
        puts "Running #{command_line}"
        example_info = []
        state = :progress
        IO.popen(command_line).each do |line|
          line.force_encoding 'UTF-8'
          case state
            when :progress
              puts line
            when :example_info
              example_info << line
          end
          state = case line
                    when /BEGIN JSON/
                      :example_info
                    else
                      state
                  end
        end.close
        {
            example_info: example_info,
            success: $?.success?
        }
      end

      def parse_results(results)
        JSON.parse results[:example_info].join("\n")
      end

      def rake_tasks_for(name)
        Opal::RSpec::RakeTask.new(name) do |server, task|
          stub_requires
          files = get_file_list
          with_sub = sub_in_end_of_line files
          multi_regex = remove_multiline_regexes with_sub
          task.files = multi_regex
          append_additional_load_paths server
          server.debug = ENV['OPAL_DEBUG']
        end

        desc "Verifies that #{name} work correctly"
        task "verify_#{name}" do
          results = execute_specs name
          parsed_results = parse_results results
          summary = parsed_results['summary']
          total = summary['example_count']
          failed = summary['failure_count']
          pending = summary['pending_count']
          actual_failures = parsed_results['examples']
                                .select { |ex| ex['status'] == 'failed' }
          expected_failures = get_ignored_spec_failures
          each_header = '----------------------------------------------------'
          used_exclusions = []
          remaining_failures = actual_failures.reject do |actual|
            expected_failures.any? do |expected|
              matches = Regexp.new(expected[:exclusion]).match actual['full_description']
              used_exclusions << expected if matches
              matches
            end
          end.map do |example|
            [
                each_header,
                'Example: '+example['full_description'],
                each_header,
                example['exception']['message']
            ].join "\n"
          end
          reasons = []
          unless remaining_failures.empty?
            reasons << 'Unexpected failures'
          end
          reasons << "Expected #{expected_pending_count} pending but got #{pending}" unless pending == expected_pending_count
          reasons << 'no specs found' unless total > 0
          reasons << 'No failures, but Rake task did not succeed' if (failed == 0 && !results[:success])
          unused_exclusions = expected_failures.uniq - used_exclusions.uniq
          if unused_exclusions.any?
            msg = "WARNING: The following exclusion rules did not match an actual failure. Time to update exclusions? Duplicate exclusions??\n" +
                unused_exclusions.map { |e| "File: #{e[:filename]}\nLine #{e[:line_number]}\nFilter: #{e[:exclusion]}" }.join("\n---------------------\n")
            reasons << msg
          end
          if reasons.empty?
            puts 'Test successful!'
            puts "#{total} total specs, #{failed} expected failures, #{pending} expected pending"
          else
            puts "Test FAILED for the following reasons:\n"
            puts reasons.join "\n\n"
            if remaining_failures.any?
              puts
              puts "Unexpected failures:\n\n#{remaining_failures.join("\n")}\n"
            end
            puts '-----------Summary-----------'
            puts "Total passed count: #{total - failed - pending}"
            puts "Pending count #{pending}"
            puts "Total 'failure' count: #{actual_failures.length}"
            puts "Unexpected failure count: #{remaining_failures.length}"
            raise 'Test failed!'
          end
        end
      end

      def run_rack_server(rack)
        Opal::Processor.source_map_enabled = false

        files = get_file_list
        with_sub = sub_in_end_of_line files
        multi_regex = remove_multiline_regexes with_sub
        sprockets_env = Opal::RSpec::SprocketsEnvironment.new(spec_pattern=nil, spec_exclude_pattern=nil, spec_files=multi_regex)
        rack.run Opal::Server.new(sprockets: sprockets_env) { |s|
                   s.main = 'opal/rspec/sprockets_runner'
                   stub_requires
                   sprockets_env.add_spec_paths_to_sprockets
                   append_additional_load_paths s
                   s.debug = ENV['OPAL_DEBUG']
                 }
      end

      private

      def get_exclusions_compact(filename)
        line_num = 0
        File.read(filename).split("\n").map do |line|
          line_num += 1
          {
              exclusion: line,
              filename: filename,
              line_number: line_num
          }
        end.reject do |line|
          exclusion = line[:exclusion]
          exclusion.empty? or exclusion.start_with? '#'
        end
      end
    end
  end
end
