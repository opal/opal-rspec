rspec_filter 'hooks' do
  # promise, see opal alternates
  filter /RSpec::Core::Hooks when an error happens in.* allows the error to propagate to the user/

  # promise, for some reason succeeds on Opal 0.8, see opal alternates
  filter('RSpec::Core::Hooks#around does not consider the hook to have run when passed as a block to a method that does not yield').if { at_least_opal_0_9? }
  filter('RSpec::Core::Hooks#around when it does not run the example for a hook declared in the group converts the example to a skipped example so the user is made aware of it')
      .if { at_least_opal_0_9? }
  filter('RSpec::Core::Hooks#around when it does not run the example for a hook declared in config converts the example to a skipped example so the user is made aware of it')
      .if { at_least_opal_0_9? }
end
