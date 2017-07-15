class ::RSpec::Core::Reporter
  def report(expected_example_count)
    start(expected_example_count)
    yield(self).ensure do |result|
      finish
      result
    end
  end
end
