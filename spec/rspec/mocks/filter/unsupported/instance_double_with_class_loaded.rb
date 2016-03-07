rspec_filter 'instance_double_with_class_loaded' do
  # depends on private methods
  filter 'An instance double with the doubled class loaded gives a descriptive error message for NoMethodError'
  filter 'An instance double with the doubled class loaded for null objects reports that it responds to protected methods when the appropriate arg is passed'
  filter 'An instance double with the doubled class loaded for null objects reports that it responds to defined private methods when the appropriate arg is passed'
  filter "An instance double with the doubled class loaded for null objects includes the double's name in a private method error"

  # arity, Opal 0.9 can't tell the difference between send(*) and send() right now
  filter('An instance double with the doubled class loaded allows `send` to be stubbed if it is defined on the class').unless { arity_checking_working? }
end
