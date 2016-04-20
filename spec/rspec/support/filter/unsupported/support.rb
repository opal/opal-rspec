rspec_filter 'support' do
  # evals code
  filter 'RSpec::Support behaves like a library that issues no warnings when loaded issues no warnings when loaded'

  # threads
  filter 'RSpec::Support failure notification isolates notifier changes to the current thread'
end
