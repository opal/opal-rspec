rspec_filter 'and_yield' do
  # some sort of complex arity problem pertaining to eval'ed code
  filter 'RSpec::Mocks::Double#and_yield with eval context as block argument and yielded arguments that are optional yields given argument when the argument is given'
end
