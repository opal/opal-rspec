require 'tmpdir'
require_relative 'filter_processor'

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

      def post_requires
        []
      end

      def get_ignored_spec_failures
        text_based = FileList[File.join(base_dir, 'filter/**/*.txt')].map do |filename|
          get_compact_text_expressions filename, wrap_in_regex=true
        end.flatten
        processor = FilterProcessor.new
        FileList[File.join(base_dir, 'filter/**/*.rb')].exclude('**/sandbox/**/*').each do |filename|
          processor.filename = filename
          contents = File.read filename
          processor.instance_eval contents
        end
        text_based + processor.all_filters
      end

      def stub_requires
        stubbed_requires.each { |f| ::Opal::Config.stubbed_files << f }
        unstub_requires.each do |f|
          puts "Unstubbing #{f} per test request"
          ::Opal::Config.stubbed_files.delete f
        end
      end

      def symbols_replace_regexes
        [
            /(fail_\w+)\((.*)\)/,
            /(expect.*description\)\.to eq)\((.*)\)/,
            /(expect.*description\)\.to eq) (.*)/
        ]
      end

      def symbol_do_not_replace_regexes
        []
      end

      def symbols_in_expectations(files)
        matching = symbols_replace_regexes
        # fail_with(/expected .* to respond to :some_method/)
        replace_with_regex matching, 'fix symbols in message expectations', files, symbol_files do |match, temp_filename|
          next match.to_s if symbol_do_not_replace_regexes.any? { |exp| exp.match match.to_s }
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

      def get_file_list
        exclude_these_specs = get_compact_text_expressions File.join(base_dir, 'spec_files_exclude.txt'), wrap_in_regex=false
        exclude_globs_only = exclude_these_specs.map { |f| f[:exclusion] }
        files = FileList[
            File.join(base_dir, 'require_specs.rb'), # need our code to go in first
            *spec_glob
        ].exclude(*exclude_globs_only)
        missing_exclusions = exclude_these_specs.reject do |exclude|
          FileList[exclude[:exclusion]].any?
        end
        if missing_exclusions.any?
          raise "Expected to exclude #{missing_exclusions} as noted in spec_files_exclude.txt but we didn't find these files. Has RSpec been upgraded?"
        end
        files += post_requires.map { |r| File.join(base_dir, r) }
        puts 'Running the following RSpec specs:'
        files.each { |f| puts f }
        files
      end

      def append_additional_load_paths(server)
        baseline = [base_dir, 'spec/rspec/shared']
        baseline += tmp_load_paths
        (baseline + additional_load_paths).each { |p| server.append_path p }
      end

      def get_tmp_load_path_dir
        dir = Dir.mktmpdir
        at_exit do
          FileUtils.remove_entry dir
        end
        # something was clearing this if it was added via Opal.append_path, so save it
        tmp_load_paths << dir
        dir
      end

      def tmp_load_paths
        @tmp_load_paths ||= []
      end

      def replace_with_regex(regex, description, starting_file_set, files_to_replace)
        fix_these_files = starting_file_set.select { |f| files_to_replace.any? { |r| r.match(f) } }
        return starting_file_set unless fix_these_files.any?
        dir = get_tmp_load_path_dir
        missing = []
        expressions = [*regex]
        fixed_temp_files = fix_these_files.map do |path|
          temp_filename = File.join dir, File.basename(path)
          input = File.read path
          matching = false
          expressions.each do |r|
            match = r.match input
            if match
              matching = true
              input.gsub!(r) do |_|
                yield Regexp.last_match, temp_filename
              end
            end
          end
          File.open temp_filename, 'w' do |output_file|
            output_file.write input
          end
          missing << path unless matching
          temp_filename
        end
        raise "~~> Expected to #{description} in #{fix_these_files} but we didn't find any expressions in #{missing}. Check if RSpec has been upgraded" if missing.any?
        files_we_left_alone = starting_file_set - fix_these_files
        files_we_left_alone + fixed_temp_files
      end

      # https://github.com/opal/opal/issues/1125
      def remove_multiline_regexes(files)
        replace_with_regex /(%r%$.*%)$/m, 'fix multiline regex', files, files_with_multiline_regex do |match, temp_filename|
          multi_line_regex = match
                                 .captures[0]
                                 .gsub("\n", '')
          parsed = instance_eval multi_line_regex # can just have ruby do this for us
          escaped = parsed
                        .source
                        .gsub('/', '\/')
          replace = "/#{escaped}/m"
          puts "~~> Replacing multiline regex with #{replace} in new temp file #{temp_filename}"
          replace
        end
      end

      def sub_in_files
        files = get_file_list
        with_sub = sub_in_end_of_line files
        remove_multiline_regexes with_sub
      end

      # https://github.com/opal/opal/issues/821
      def sub_in_end_of_line(files)
        bad_regex = /^(.*)\\$/
        fix_these_files = files.select { |f| files_with_line_continue.any? { |regex| regex.match(f) } }
        return files unless fix_these_files.any?
        dir = get_tmp_load_path_dir
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
        raise "~~> Expected to fix blackslash continuation in #{fix_these_files} but we didn't find any backslashes in #{missing}. Check if RSpec has been upgraded (maybe those blackslashes are gone??)" if missing.any?
        files_we_left_alone = files - fix_these_files
        files_we_left_alone + fixed_temp_files
      end

      def execute_specs(name)
        require 'tempfile'
        file = Tempfile.new([name.to_s, '.json'])
        command = "SPEC_OPTS=\"--no-color --format progress --format Opal::RSpec::SeparatorFormatter --format json\" rake #{name} --trace > #{file.path}"
        puts
        puts "~~> Running #{command}"

        # travis/keep alive
        pinger = Thread.new { loop { sleep 60; print '.' } }
        success = system(command)
        pinger.exit

        file.rewind
        ouput = file.read
        ouput.force_encoding 'UTF-8'
        progress, example_info = ouput.split('~~~SEPARATOR~~~', 2)

        {
          example_info: [example_info],
          success: success
        }
      end

      def parse_results(results)
        JSON.parse results[:example_info].join("\n")
      rescue
        warn "JSON PARSING FAILED"
        warn "-------------------"
        warn results[:example_info].join("\n")
        warn "-------------------"
        raise
      end

      def rake_tasks_for(name)
        Opal::RSpec::RakeTask.new(name) do |server, task|
          # A lot of specs, can take longer on slower machines
          task.timeout = 80000
          stub_requires
          task.files = sub_in_files
          task.default_path = default_path
          append_additional_load_paths server

          server.debug = ENV['OPAL_DEBUG'] if server.respond_to?(:debug=)
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
          used_exclusions = []
          remaining_failures = actual_failures.reject do |actual|
            expected_failures.any? do |expected|
              exclusion = expected[:exclusion]
              actual_descr = actual['full_description']
              matches = case exclusion
                          when Regexp
                            exclusion.match actual_descr
                          when String
                            exclusion == actual_descr
                          else
                            raise "Unknown filter expression type #{exclusion.class} in #{expected}!"
                        end
              used_exclusions << expected if matches
              matches
            end
          end
          each_header = '----------------------------------------------------'
          index = 0
          remaining_failures = remaining_failures.map do |example|
            index += 1
            [
                each_header,
                "Example #{index}: #{example['full_description']}",
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
            msg = "WARNING: The following #{unused_exclusions.length} exclusion rules did not match an actual failure. Time to update exclusions? Duplicate exclusions??\n" +
                unused_exclusions.map { |e| "File: #{e[:filename]}\nLine #{e[:line_number]}\nFilter: #{e[:exclusion]}" }.join("\n---------------------\n")
            reasons << msg
          end
          passing = total - failed - pending
          percentage = ((passing.to_f / total) * 100).round(1)
          if reasons.empty?
            puts '~~> Test successful!'
            puts "~~> #{total} total specs, #{failed} expected failures, #{pending} expected pending"
            puts "~~> Passing percentage: #{percentage}%"
          else
            puts "~~> Test FAILED for the following reasons:\n"
            puts reasons.join "\n\n"
            if remaining_failures.any?
              puts
              puts "~~> Unexpected failures:\n\n#{remaining_failures.join("\n")}\n"
            end
            puts '~~> -----------Summary-----------'
            puts "~~> Total passed count: #{passing}"
            puts "~~> Pending count #{pending}"
            puts "~~> Total 'failure' count: #{actual_failures.length}"
            puts "~~> Passing percentage: #{percentage}%"
            puts "~~> Unexpected failure count: #{remaining_failures.length}"
            raise '~~> Test failed!'
          end
        end
      end

      def run_rack_server(rack)
        only_name = self.name.split('::').last

        files = sub_in_files
        sprockets_env = Opal::RSpec::SprocketsEnvironment.new(spec_pattern=nil, spec_exclude_pattern=nil, spec_files=files)
        sprockets_env.default_path = default_path
        sprockets_env.cache = ::Sprockets::Cache::FileStore.new(File.join('tmp', 'cache', only_name))
        Opal::Config.arity_check_enabled = true
        rack.run Opal::Server.new(sprockets: sprockets_env) { |s|
                   s.main = 'opal/rspec/sprockets_runner'
                   stub_requires
                   append_additional_load_paths s
                   sprockets_env.add_spec_paths_to_sprockets
                   s.debug = ENV['OPAL_DEBUG']
                   s.source_map = ENV['OPAL_DEBUG'] != nil
                 }
      end

      private

      def get_compact_text_expressions(filename, wrap_in_regex)
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
        end.map do |filter|
          wrap_in_regex ? filter.merge({exclusion: Regexp.new(filter[:exclusion])}) : filter
        end
      end
    end
  end
end
