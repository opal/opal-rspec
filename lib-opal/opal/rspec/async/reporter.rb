# await: *await*

class ::RSpec::Core::Reporter
  def report_await(expected_example_count)
    # WAS:
    #   start(expected_example_count)
    #   begin
    #     yield self
    #   ensure
    #     finish
    #   end
    # NOW:
    start(expected_example_count)
    begin
      yield(self).await
    ensure
      finish
    end
  end
end
