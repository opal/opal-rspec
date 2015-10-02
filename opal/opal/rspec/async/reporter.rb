class ::RSpec::Core::Reporter
  def report_async(expected_example_count)
    start(expected_example_count)
    yield(self).ensure do |result|
      finish
      result
    end
  end
end
