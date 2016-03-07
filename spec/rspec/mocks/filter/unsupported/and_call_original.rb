rspec_filter 'and_call_original' do
  # arity on opal 0.9
  filter('and_call_original on a partial double errors when you pass through the wrong number of args').unless { arity_checking_working? }

  # backtrace/line #
  filter 'and_call_original on a partial double warns when you override an existing implementation'
end
