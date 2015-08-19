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
    end
  end
end
