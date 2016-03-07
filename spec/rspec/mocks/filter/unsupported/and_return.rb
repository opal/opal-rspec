rspec_filter 'and_return' do
  # arity checking disabled on 0.9, so not catching this
  filter('and_return when no argument is passed raises ArgumentError').unless { arity_checking_working? }
end
