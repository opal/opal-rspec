require 'tmpdir'

module Opal
  module RSpec
    class Stubbing
      def self.stub_requires
        [
          'rubygems',
          'aruba/api', # Cucumber lib that supports file creation during testing, N/A for us
          'simplecov', # hooks aren't available on Opal
          'tmpdir',
          'rspec/support/spec/shell_out', # only does stuff Opal can't support anyways
          'rspec/support/spec/prevent_load_time_warnings'
        ].each {|f| Opal::Processor.stub_file f}
      end
      
      def self.get_file_list
        exclude = File.read('spec/rspec_provided/spec_files_exclude.txt').split("\n").reject do |line|
          line.empty? or line.start_with? '#'
        end
        files = FileList['spec/rspec_provided/rspec_spec_fixes.rb', 'rspec-core/spec/**/*_spec.rb'].exclude(*exclude)
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
        files_with_line_continue = [/core\/example_spec.rb/, /pending_spec.rb/]
        bad_regex = /^(.*)\\$/
        fix_these_files = files.select {|f| files_with_line_continue.any? {|regex| regex.match(f)}}
        dir = Dir.mktmpdir
        fixed_temp_files = fix_these_files.map do |path|
          temp_filename = File.join dir, File.basename(path)
          File.open path, 'r' do |input_file|
            File.open temp_filename, 'w' do |output_file|
              last_line_has_slash = false
              fixed_lines = input_file.inject do |line1, line2|
                existing_lines = [*line1]
                if (a_match = bad_regex.match existing_lines.last)
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
          temp_filename
        end                
        at_exit do
          FileUtils.remove_entry dir
        end
        files_we_left_alone = files - fix_these_files
        files_we_left_alone + fixed_temp_files
      end
    end
  end
end
