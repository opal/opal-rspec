rspec_filter 'contain_exactly' do
  # https://github.com/opal/opal/pull/1136 - operators and method missing issues with a_value > < etc
  filter /should_not =~ \[:with, :multiple, :args\] fails when the arrays match.*/
  unless at_least_opal_0_9?
    filter('should =~ array when the array undefines `=~` still works')
    filter('using contain_exactly with expect passes for an out of order valid positive expectation with hashes')
    filter('using contain_exactly with expect passes for an in order valid positive expectation with hashes')
  end
  filter('should =~ array when the array defines a `send` method still works')
  filter('should =~ array when the array defines a `=~` method delegates to that method rather than using the contain_exactly matcher')
  filter('should =~ array fails an invalid positive expectation')
  filter('should =~ array passes a valid positive expectation')
end
