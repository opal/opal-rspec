rspec_filter 'memoized_helpers' do
  # These depend on https://github.com/opal/opal/issues/1124, but you can only reproduce that with Opal 0.9
  filter 'RSpec::Core::MemoizedHelpers explicit subject with a name when `super` is used raises a "not supported" error'
  filter 'RSpec::Core::MemoizedHelpers explicit subject with a name when `super` is used with a `let` definition before the named subject raises a "not supported" error'

  # This works right in Opal 0.9 (see sandbox/subject_issue_test), might be something with the class scoping PR (https://github.com/opal/opal/pull/1114) that requires compiler changes to fix
  filter("RSpec::Core::MemoizedHelpers explicit subject with a name yields the example in which it is eval'd").unless { at_least_opal_0_9? }

  # This works right in Opal 0.9 (Class === Enumerable), might be https://github.com/opal/opal/commit/304ab9c464754ca54ab03f1f31d5c137ae8e995d but not sure
  filter('RSpec::Core::MemoizedHelpers implicit subject with a Module returns the Module').unless { at_least_opal_0_9? }
end
