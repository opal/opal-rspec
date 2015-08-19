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
      
      def self.append_paths(server)
        [
          'rspec-core/spec',
          'rspec-support/spec',
          'rspec-support/lib'
        ].each {|f| server.append_path f }
      end
    end
  end
end
