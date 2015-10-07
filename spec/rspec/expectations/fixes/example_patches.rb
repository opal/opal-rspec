module Opal
  module RSpec
    def self.get_constants_for(object)
      result = []
      %x{
        for (var prop in #{object}) {
          if (#{object}.hasOwnProperty(prop) && #{!`prop`.start_with?('$')}) {
            #{result << `prop`}
          }
        }
      }
      result.reject { |c| c == 'constructor' }
    end
  end
end

unless Opal::RSpec::Compatibility.constant_resolution_works_right?
  example_group = RSpec::ExampleGroups.const_get 'BuiltInMatchers'
  example_group.let(:matchers) do
    # .constants is broken in Opal, this is a hack
    constants = Opal::RSpec.get_constants_for(RSpec::Matchers::BuiltIn) - [:NullCapture, :CaptureStdOut, :CaptureStdErr]
    constants.map { |n| RSpec::Matchers::BuiltIn.const_get(n) }.select do |m|
      #BuiltIn.constants.map { |n| BuiltIn.const_get(n) }.select do |m|
      m.method_defined?(:matches?) && m.method_defined?(:failure_message)
    end
  end
end
