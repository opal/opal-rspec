require 'tmpdir'
require_relative 'filter_processor'
require_relative 'support/colors'
require 'opal-rspec'

module Opal
  module RSpec
    module OpalRSpecSpecLoader
      include Rake::DSL
      include Colors

      def files_with_multiline_regex
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
          patching("symbol-fix: replacing #{match.to_s} with #{new}", temp_filename)
          new
        end
      end

      def get_file_list
        exclude_these_specs = get_compact_text_expressions File.join(base_dir, 'spec_files_exclude.txt'), wrap_in_regex=false
        exclude_globs_only = exclude_these_specs.map { |f| f[:exclusion] }
        files = FileList[
            # "#{__dir__}/../../lib-opal-spec-support/opal-rspec-core/require_specs.rb", # need our code to go in first
            *spec_glob
        ].exclude(*exclude_globs_only)
        missing_exclusions = exclude_these_specs.reject do |exclude|
          FileList[exclude[:exclusion]].any?
        end
        if missing_exclusions.any?
          raise "Expected to exclude #{missing_exclusions} as noted in spec_files_exclude.txt but we didn't find these files. Has RSpec been upgraded?"
        end
        files += post_requires.map { |r| File.join(base_dir, r) }
        files.each { |f| running_file f }
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
        raise "Expected to #{description} in #{fix_these_files} but we didn't find any expressions in #{missing}. Check if RSpec has been upgraded" if missing.any?
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
          patching("Replacing multiline regex with #{replace}", temp_filename)
          replace
        end
      end

      def sub_in_files
        files = get_file_list
        remove_multiline_regexes files
      end

      def run_specs
        # command_line = runner.command
        # # command_line = "SPEC_OPTS=\"--format Opal::RSpec::ProgressJsonFormatter\" #{command_line}"
        # command_line = "bundle exec #{command_line}"
        # puts "Running #{command_line}"
        # lines = []

        # keepalive_travis do
        #   IO.popen(command_line).each do |line|
        #     lines << line.force_encoding('UTF-8')
        #   end.close
        # end
        # success = $?.success?
        # output = lines.join
        # default_formatted, json_formatted = output.split(/BEGIN JSON/)
        output_io = StringIO.new
        previous_stdout = $stdout
        previous_stderr = $stderr
        $stdout = output_io
        $stderr = output_io
        begin
          exit_status = runner.run
        ensure
          $stdout = previous_stdout
          $stderr = previous_stderr
        end

        output_io.rewind

        Result.new(
          exit_status,
          output_io.read,
          JSON.parse(File.read('/tmp/spec_results.json'), symbolize_names: true),
        )
      end

      class Result < Struct.new(:exit_status, :output, :json)
        def quoted_output
          output.gsub(/(\A|\n)/, '\1> ')
        end

        def successful?
          exit_status == 0
        end

        def inspect
          "#<struct #{self.class.name} exit_status=#{exit_status} summary=#{json[:summary_line].inspect}>"
        end

        alias to_s inspect
      end

      def keepalive_travis
        return yield unless ENV['TRAVIS']
        travis_keepalive = Thread.new { loop { sleep 60; puts 'still alive' } }
        result = yield
        travis_keepalive.exit
        result
      end

      def base_dir
        "spec/rspec/#{short_name}"
      end

      def default_path
        "rspec-#{short_name}/spec"
      end


      def runner
        @runner ||= ::Opal::RSpec::Runner.new do |server, task|
          # A lot of specs, can take longer on slower machines
          # task.timeout = 80000
          stub_requires
          task.files = sub_in_files
          task.default_path = default_path
          append_additional_load_paths server
          server.debug = ENV['OPAL_DEBUG']
          task.requires += ["opal/rspec/upstream-specs-support/#{short_name}/require_specs"]
        end
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
