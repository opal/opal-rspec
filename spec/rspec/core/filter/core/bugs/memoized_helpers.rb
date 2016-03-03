rspec_filter 'memoized_helpers' do
  # These depend on https://github.com/opal/opal/issues/1124, but you can only reproduce that with Opal 0.9
  filter 'RSpec::Core::MemoizedHelpers explicit subject with a name when `super` is used raises a "not supported" error'
  filter 'RSpec::Core::MemoizedHelpers explicit subject with a name when `super` is used with a `let` definition before the named subject raises a "not supported" error'
end
