class ::RSpec::Core::Reporter
  def report(expected_example_count)
    # WAS:
    #   start(expected_example_count)
    #   begin
    #     yield self
    #   ensure
    #     finish
    #   end
    # NOW:
    start(expected_example_count)
    yield(self).ensure do |result|
      finish
      result
    end
  end
end
