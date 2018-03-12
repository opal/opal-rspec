require 'opal/rspec/upstream-specs-support/opal_filters'

OpalFilters.group('Bugs') do
  fails "RSpec::Support::StdErrSplitter will fail an example which generates a warning",  "expected Exception with message matching /Warnings were generated:/ but nothing was raised"
  fails "rspec warnings and deprecations works when required in isolation",  "undefined method `run_ruby_with_current_load_path' for #<RSpec::ExampleGroups::RspecWarningsAndDeprec"
  fails "rspec warnings and deprecations when rspec-core is not available behaves like falling back to Kernel.warn falls back to warning with a plain message",  "String#<< not supported. Mutable String methods are not supported in Opal."
  fails "rspec warnings and deprecations when rspec-core is not available behaves like falling back to Kernel.warn handles being passed options",  "String#<< not supported. Mutable String methods are not supported in Opal."
  fails "rspec warnings and deprecations when rspec-core is not available behaves like falling back to Kernel.warn falls back to warning with a plain message",  "String#<< not supported. Mutable String methods are not supported in Opal."
  fails "rspec warnings and deprecations when rspec-core is not available behaves like falling back to Kernel.warn handles being passed options",  "String#<< not supported. Mutable String methods are not supported in Opal."
  fails "rspec warnings and deprecations #warning prepends WARNING:",  "String#<< not supported. Mutable String methods are not supported in Opal."
  fails "rspec warnings and deprecations #warning it should behave like warning helper warns with the message text",  "String#<< not supported. Mutable String methods are not supported in Opal."
  fails "rspec warnings and deprecations #warning it should behave like warning helper sets the calling line",  "String#<< not supported. Mutable String methods are not supported in Opal."
  fails "rspec warnings and deprecations #warning it should behave like warning helper optionally sets the replacement",  "String#<< not supported. Mutable String methods are not supported in Opal."
  fails "rspec warnings and deprecations #warn_with message, options it should behave like warning helper warns with the message text",  "String#<< not supported. Mutable String methods are not supported in Opal."
  fails "rspec warnings and deprecations #warn_with message, options it should behave like warning helper sets the calling line",  "String#<< not supported. Mutable String methods are not supported in Opal."
  fails "rspec warnings and deprecations #warn_with message, options it should behave like warning helper optionally sets the replacement",  "String#<< not supported. Mutable String methods are not supported in Opal."
end
