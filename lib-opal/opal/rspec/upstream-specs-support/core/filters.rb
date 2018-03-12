require 'opal/rspec/upstream-specs-support/opal_filters'

OpalFilters.group("Bugs: Backtrace") do
  fails "RSpec::Core::World#preceding_declaration_line (again) with one example returns the argument line number if an example starts on that line",  "expected: 1"
  fails "RSpec::Core::World#preceding_declaration_line (again) with one example returns line number of an example that immediately precedes the argument line",  "expected: 1"
end

OpalFilters.group("Unsupported") do
  # fails "RSpec::Core::ExampleGroup minimizes the number of methods that users could inadvertantly overwrite", "extra method coming from opal"
  # fails 'RSpec::Core::FilterManager#prune prefers location to exclusion filter', 'unsupported source location'
  # fails 'RSpec::Core::FilterManager#prune prefers location to exclusion filter on entire group', 'unsupported source location'
  # fails 'RSpec::Core::FilterManager#inclusions#description cleans up the description', 'expects Proc#inspect to include source location'
  # fails 'RSpec::Core::FilterManager#exclusions#description cleans up the description', 'expects Proc#inspect to include source location'
end

OpalFilters.group("Bugs") do
  fails "RSpec::Core::Notifications::FailedExampleNotification uses the default color for the shared example backtrace line",  "expected [\"\\e[31mFailure/Error: Unable to find matching line from backtrace\\e[0m\", \"\\e[31m  \\e[0m\", \"\\e[31m  expected: 2\\e[0m\", \"\\e[31m       got: 1\\e[0m\", \"\\e[31m  \\e[0m\", \"\\e[31m  (compared using ==)\\e[0m\", \"\\e[31m\\e[37mShared Example Group: \\\"a\\\" called from \\e[0m\\e[0m\"] to include (match \"\\\\e\\\\[37mShared Example Group:\")"
  fails "FailedExampleNotification #read_failed_line when ruby reports a bogus line number in the stack trace reports the filename and that it was unable to find the matching line",  "expected \"Unable to find /Users/elia/Code/opal-rspec/rspec-core/spec/rspec/core/notifications_spec to read failed line\" to include \"Unable to find matching line\""
  fails "FailedExampleNotification #read_failed_line when String alias to_int to_i doesn't hang when file exists",  "\nexpected: \"let(:exception) { instance_double(Exception, :backtrace => [ \\\"\\\#{__FILE__}:\\\#{__LINE__}\\\"]) }\"\n     got: \"Unable to find /Users/elia/Code/opal-rspec/rspec-core/spec/rspec/core/notifications_spec to read failed line\"\n\n(compared using eql?)\n"
  fails "FailedExampleNotification #message_lines should return failure_lines without color",  "could not find current class for super()"
  fails "FailedExampleNotification #message_lines returns failures_lines without color when they are part of a shared example group",  "could not find current class for super()"

  fails "RSpec::Core::Example when there is no explicit description when RSpec.configuration.format_docstrings is set to a block formats the description using the block",  "expected \"EXAMPLE AT \" to match /EXAMPLE AT \\/VAR\\/FOLDERS\\/W0\\/YJFQR9N94LD7FT4J3HLZ_FSM0000GN\\/T\\/D20170924-23861-ZF96QT\\/EXAMPLE_SPEC:70/"
  fails "RSpec::Core::Example when there is no explicit description when `expect_with :rspec` is configured uses the file and line number if there is no matcher-generated description",  "expected \"example at \" to match /example at \\/var\\/folders\\/w0\\/yjfqr9n94ld7ft4j3hlz_fsm0000gn\\/T\\/d20170924-23861-zf96qt\\/example_spec:93/"
  fails "RSpec::Core::Example when there is no explicit description when `expect_with :rspec` is configured uses the file and line number if there is an error before the matcher",  "expected \"example at \" to match /example at \\/var\\/folders\\/w0\\/yjfqr9n94ld7ft4j3hlz_fsm0000gn\\/T\\/d20170924-23861-zf96qt\\/example_spec:99/"
  fails "RSpec::Core::Example when there is no explicit description when `expect_with :rspec` is configured if the example is pending uses the file and line number of the example if no matcher ran",  "expected \"example at \" to match /example at \\/var\\/folders\\/w0\\/yjfqr9n94ld7ft4j3hlz_fsm0000gn\\/T\\/d20170924-23861-zf96qt\\/example_spec:113/"
  fails "RSpec::Core::Example when there is no explicit description when `expect_with :rspec, :stdlib` is configured uses the file and line number if there is no matcher-generated description",  "expected \"example at \" to match /example at \\/var\\/folders\\/w0\\/yjfqr9n94ld7ft4j3hlz_fsm0000gn\\/T\\/d20170924-23861-zf96qt\\/example_spec:130/"
  fails "RSpec::Core::Example when there is no explicit description when `expect_with :rspec, :stdlib` is configured uses the file and line number if there is an error before the matcher",  "expected \"example at \" to match /example at \\/var\\/folders\\/w0\\/yjfqr9n94ld7ft4j3hlz_fsm0000gn\\/T\\/d20170924-23861-zf96qt\\/example_spec:136/"
  fails "RSpec::Core::Example when there is no explicit description when `expect_with :stdlib` is configured uses the file and line number",  "expected \"example at \" to match /example at \\/var\\/folders\\/w0\\/yjfqr9n94ld7ft4j3hlz_fsm0000gn\\/T\\/d20170924-23861-zf96qt\\/example_spec:153/"
  fails "RSpec::Core::Example#run when the example raises an error leaves a raised exception unmodified (GH-1103)",  "undefined method `set_backtrace' for #<StandardError: StandardError>:StandardError"
  fails "RSpec::Core::Example#pending in the example sets the backtrace to the example definition so it can be located by the user",  "\nexpected: [\"/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/d20170924-23861-zf96qt/example_spec\", \"447\"]\n     got: [\"PendingExampleFixedError\", \" Expected example to fail since it is pending, but it passed.\"]\n\n(compared using ==)\n"

  fails "RSpec::Core::ExampleGroup constant naming disambiguates name collisions by appending a number",  "expected RSpec::ExampleGroups::Collisioo_0 to have class const \"Collision_10\""
  fails "RSpec::Core::ExampleGroup ordering when tagged with an unrecognized ordering prints a warning so users are notified of their mistake",  "expected \"WARNING: Ignoring unknown ordering specified using `:order => \\\"unrecognized\\\"` metadata.\\n         Falling back to configured global ordering.\\n         Unrecognized ordering specified at: \\n\" to match /example_group_spec:182/"
  fails "RSpec::Core::ExampleGroup#metadata adds the the file_path to metadata",  "\nexpected: \"/Users/elia/Code/opal-rspec/rspec-core/spec/rspec/core/example_group_spec\"\n     got: \"\"\n\n(compared using ==)\n"
  fails "RSpec::Core::ExampleGroup#metadata has a reader for file_path",  "\nexpected: \"/Users/elia/Code/opal-rspec/rspec-core/spec/rspec/core/example_group_spec\"\n     got: \"\"\n\n(compared using ==)\n"
  fails "RSpec::Core::ExampleGroup#metadata adds the line_number to metadata",  "\nexpected: 610\n     got: -1\n\n(compared using ==)\n"
  fails "RSpec::Core::ExampleGroup.pending sets the backtrace to the example definition so it can be located by the user",  "\nexpected: [\"/Users/elia/Code/opal-rspec/rspec-core/spec/rspec/core/example_group_spec\", \"946\"]\n     got: [\"PendingExampleFixedError\", \" Expected example to fail since it is pending, but it passed.\"]\n\n(compared using ==)\n"

  fails "RSpec::Core::ExampleGroup minimizes the number of methods that users could inadvertantly overwrite",  "expected collection contained:  [\"described_class\", \"is_expected\", \"pending\", \"setup_mocks_for_rspec\""
  fails "RSpec::Core::FilterManager#prune prefers location to exclusion filter",  "expected: [#<RSpec::Core::Example:0x126c4>]"
  fails "RSpec::Core::FilterManager#prune prefers location to exclusion filter on entire group",  "expected: [#<RSpec::Core::Example:0x127aa>]"
  fails "RSpec::Core::FilterManager#inclusions#description cleans up the description",  "expected \"#<Proc:0x130e6>\" to include \"/Users/elia/Code/opal-rspec\""
  fails "RSpec::Core::FilterManager#exclusions#description cleans up the description",  "expected \"#<Proc:0x1317a>\" to include \"/Users/elia/Code/opal-rspec\""
  fails "RSpec::Core::Formatters::BaseTextFormatter when closing the formatter does not close an already closed output stream",  "undefined method `mktmpdir' for Dir"
  fails "RSpec::Core::Formatters::BaseTextFormatter#dump_summary includes command to re-run each failed example",  "expected \"\\nFinished in 1 second (files took 0 seconds to load)\\n1 example, 1 failure\\n\\nFilter faile"
  fails "RSpec::Core::Formatters::BaseTextFormatter#dump_failures with an exception that has a differently encoded message runs without encountering an encoding exception",  "expected \"\\nFailures:\\n\\n  1) group name Mixing encodings, e.g. UTF-8: © and Binary\\n     Failure/Err"
  fails "RSpec::Core::Formatters::BaseTextFormatter#dump_failures with a failed expectation (rspec-expectations) does not show the error class",  "expected \"\\nFailures:\\n\\n  1) group name example name\\n     Failure/Error: Unable to find matching li"
  fails "RSpec::Core::Formatters::BaseTextFormatter#dump_failures with a failed message expectation (rspec-mocks) does not show the error class",  "expected \"\\nFailures:\\n\\n  1) group name example name\\n     Failure/Error: Unable to find matching li"
  fails "RSpec::Core::Formatters::BaseTextFormatter#dump_failures for #shared_examples outputs the name and location",  "expected \"\\nFailures:\\n\\n  1) group name it should behave like foo bar example name\\n     Failure/Err"
  fails "RSpec::Core::Formatters::BaseTextFormatter#dump_failures for #shared_examples that contains nested example groups outputs the name and location",  "expected \"\\nFailures:\\n\\n  1) group name it should behave like foo bar nested group example name\\n   "

  fails "rspec warnings and deprecations #deprecate passes the hash to the reporter",  "undefined method `deprecate' for RSpec"
  fails "rspec warnings and deprecations #deprecate adds the call site",  "undefined method `deprecate' for RSpec"
  fails "rspec warnings and deprecations #deprecate doesn't override a passed call site",  "undefined method `deprecate' for RSpec"
  fails "rspec warnings and deprecations #warn_with when :use_spec_location_as_call_site => true is passed adds the source location of spec",  "Kernel received \"warn\" with unexpected arguments"
  fails "rspec warnings and deprecations #warn_with when :use_spec_location_as_call_site => true is passed appends a period to the supplied message if one is not present",  "Kernel received \"warn\" with unexpected arguments"

  fails "RSpec::Core::Hooks when an error happens in `after(:suite)` allows the error to propagate to the user",  "expected ZeroDivisionError but nothing was raised"
  fails "RSpec::Core::Hooks when an error happens in `before(:suite)` allows the error to propagate to the user",  "expected ZeroDivisionError but nothing was raised"
  fails "RSpec::Core::Hooks#around does not consider the hook to have run when passed as a block to a method that does not yield",  "expected: \"pending\""
  fails "RSpec::Core::Hooks#around when it does not run the example indicates which around hook did not run the example in the pending message",  "expected: \"around hook at /Users/elia/Code/opal-rspec/rspec-core/spec/rspec/core/hooks_spec:143 did n"
  fails "RSpec::Core::Hooks#around when it does not run the example for a hook declared in the group converts the example to a skipped example so the user is made aware of it",  "expected: \"pending\""
  fails "RSpec::Core::Hooks#around when it does not run the example for a hook declared in config converts the example to a skipped example so the user is made aware of it",  "expected: \"pending\""
  fails "RSpec::Core::Metadata.relative_path transforms absolute paths to relative paths",  "expected: \".\""
  fails "RSpec::Core::Metadata for an example extracts file path from caller",  "expected {\"execution_result\"=>#<RSpec::Core::Example::ExecutionResult:0x1d280>, \"block\"=>nil, \"descri"
  fails "RSpec::Core::Metadata for an example extracts line number from caller",  "expected {\"execution_result\"=>#<RSpec::Core::Example::ExecutionResult:0x1d350>, \"block\"=>nil, \"descri"
  fails "RSpec::Core::Metadata for an example extracts location from caller",  "expected {\"execution_result\"=>#<RSpec::Core::Example::ExecutionResult:0x1d420>, \"block\"=>nil, \"descri"
  fails "RSpec::Core::Metadata :described_class in an outer group with a Symbol returns the symbol",  "expected #<String:group> => \"group\""
  fails "RSpec::Core::Metadata :description on a group with a non-string and a string concats the args",  "expected: \"Object group\""
  fails "RSpec::Core::Metadata :full_description with a 2nd arg starting with # removes the space",  "expected: \"Array#method\""
  fails "RSpec::Core::Metadata :full_description with a 2nd arg starting with . removes the space",  "expected: \"Array.method\""
  fails "RSpec::Core::Metadata :full_description with a 2nd arg starting with :: removes the space",  "expected: \"Array::method\""
  fails "RSpec::Core::Metadata :file_path finds the first non-rspec lib file in the caller array",  "expected: \"/Users/elia/Code/opal-rspec/rspec-core/spec/rspec/core/metadata_spec\""
  fails "RSpec::Core::Metadata :line_number finds the line number with the first non-rspec lib file in the backtrace",  "expected: 418"
  fails "RSpec::Core::Metadata backwards compatibility :example_group issues a deprecation warning when the `:example_group` key is accessed",  "undefined method `deprecate' for RSpec"
  fails "RSpec::Core::Metadata backwards compatibility :example_group does not issue a deprecation warning when :example_group is accessed while applying configured filterings",  "undefined method `deprecate' for RSpec"
  fails "RSpec::Core::Metadata backwards compatibility :example_group can still access the example group attributes via [:example_group]",  "undefined method `deprecate' for RSpec"
  fails "RSpec::Core::Metadata backwards compatibility :example_group can access the parent example group attributes via [:example_group][:example_group]",  "undefined method `deprecate' for RSpec"
  fails "RSpec::Core::Metadata backwards compatibility :example_group works properly with deep nesting",  "undefined method `deprecate' for RSpec"
  fails "RSpec::Core::Metadata backwards compatibility :example_group works properly with shallow nesting",  "undefined method `deprecate' for RSpec"
  fails "RSpec::Core::Metadata backwards compatibility :example_group allows integration libraries like VCR to infer a fixture name from the example description by walking up nesting structure",  "undefined method `deprecate' for RSpec"
  fails "RSpec::Core::Metadata backwards compatibility :example_group can mutate attributes when accessing them via [:example_group]",  "undefined method `deprecate' for RSpec"
  fails "RSpec::Core::Metadata backwards compatibility :example_group can still be filtered via a nested key under [:example_group] as before",  "expected true"
  fails "RSpec::Core::Metadata backwards compatibility :example_group_block returns the block",  "undefined method `deprecate' for RSpec"
  fails "RSpec::Core::Metadata backwards compatibility :example_group_block issues a deprecation warning",  "undefined method `deprecate' for RSpec"
  fails "RSpec::Core::Metadata backwards compatibility :describes on an example group metadata hash returns the described_class",  "undefined method `deprecate' for RSpec"
  fails "RSpec::Core::Metadata backwards compatibility :describes on an example group metadata hash issues a deprecation warning",  "undefined method `deprecate' for RSpec"
  fails "RSpec::Core::Metadata backwards compatibility :describes an an example metadata hash returns the described_class",  "undefined method `deprecate' for RSpec"
  fails "RSpec::Core::Metadata backwards compatibility :describes an an example metadata hash issues a deprecation warning",  "undefined method `deprecate' for RSpec"

  fails "an example declared pending with metadata uses the value assigned to :pending as the message",  "undefined method `deprecate' for RSpec"
  fails "an example declared pending with metadata sets the message to 'No reason given' if :pending => true",  "undefined method `deprecate' for RSpec"
  fails "an example declared pending with metadata passes if a mock expectation is not satisifed",  "undefined method `deprecate' for RSpec"
  fails "an example made pending with `define_derived_metadata` has a pending result if there is an error",  "undefined method `deprecate' for RSpec"
  fails "an example with no block is listed as pending with 'Not yet implemented'",  "undefined method `deprecate' for RSpec"
  fails "an example with no args is listed as pending with the default message",  "undefined method `deprecate' for RSpec"
  fails "an example with a message is listed as pending with the supplied message",  "undefined method `deprecate' for RSpec"
  fails "an example with a block fails with an ArgumentError stating the syntax is deprecated",  "undefined method `deprecate' for RSpec"

  fails "RSpec::Core::MemoizedHelpers explicit subject defined in a top level group raises an error when referenced from `before(:all)`",  "expected \"subject accessed in a `before(:context)` hook at:\\n  \\n\\n`let` and `subject` declarations a"
  fails "RSpec::Core::MemoizedHelpers explicit subject defined in a top level group raises an error when referenced from `after(:all)`",  "expected \"subject accessed in an `after(:context)` hook at:\\n  \\n\\n`let` and `subject` declarations a"
  fails "RSpec::Core::MemoizedHelpers explicit subject with a name when `super` is used raises a \"not supported\" error",  "expected: \"failed\""
  fails "RSpec::Core::MemoizedHelpers explicit subject with a name when `super` is used with a `let` definition before the named subject raises a \"not supported\" error",  "expected: \"failed\""
  fails "#let raises an error when referenced from `before(:all)`",  "expected \"let declaration `foo` accessed in a `before(:context)` hook at:\\n  \\n\\n`let` and `subject` "
  fails "#let raises an error when referenced from `after(:all)`",  "expected \"let declaration `foo` accessed in an `after(:context)` hook at:\\n  \\n\\n`let` and `subject` "
  fails "Module#define_method is still a private method",  "expected NoMethodError but nothing was raised"

  fails "RSpec::Core::Formatters::JsonFormatter outputs json (brittle high level functional test)",  "expected: {\"examples\"=>[{\"description\"=>\"succeeds\", \"full_description\"=>\"one apiece succeeds\", \"statu"
  fails "RSpec::Core::Formatters::JsonFormatter#dump_profile with multiple example groups provides the slowest example groups",  "could not find current class for super()"
  fails "RSpec::Core::Formatters::JsonFormatter#dump_profile with multiple example groups provides information",  "could not find current class for super()"
  fails "RSpec::Core::Formatters::JsonFormatter#dump_profile with multiple example groups ranks the example groups by average time",  "could not find current class for super()"

  fails "RSpec::Core::Formatters::Loader#add(formatter) when a legacy formatter is added with RSpec::LegacyFormatters loads formatters from the external gem",  "could not find current class for super()"
  fails "RSpec::Core::Formatters::Loader#add(formatter) when a legacy formatter is added with RSpec::LegacyFormatters subscribes the formatter to the notifications the adaptor implements",  "could not find current class for super()"
  fails "RSpec::Core::Formatters::Loader#add(formatter) with a 2nd arg defining the output creates a file at that path and sets it as the output",  "undefined method `tmpdir' for Dir"
  fails "RSpec::Core::Formatters::Loader#add(formatter) with a 2nd arg defining the output accepts Pathname objects for file paths",  "undefined method `tmpdir' for Dir"
  fails "RSpec::Core::Formatters::Loader#add(formatter) when a duplicate formatter exists adds the formatter for different output targets",  "undefined method `tmpdir' for Dir"

  fails "RSpec::Core::Formatters::DeprecationFormatter#deprecation with a File deprecation_stream prints a message if provided, ignoring other data",  "undefined method `tmpdir' for Dir"
  fails "RSpec::Core::Formatters::DeprecationFormatter#deprecation with a File deprecation_stream surrounds multiline messages in fenceposts",  "undefined method `tmpdir' for Dir"
  fails "RSpec::Core::Formatters::DeprecationFormatter#deprecation with a File deprecation_stream includes the method",  "undefined method `tmpdir' for Dir"
  fails "RSpec::Core::Formatters::DeprecationFormatter#deprecation with a File deprecation_stream includes the replacement",  "undefined method `tmpdir' for Dir"
  fails "RSpec::Core::Formatters::DeprecationFormatter#deprecation with a File deprecation_stream includes the call site if provided",  "undefined method `tmpdir' for Dir"
  fails "RSpec::Core::Formatters::DeprecationFormatter#deprecation_summary with a File deprecation_stream prints a count of the deprecations",  "undefined method `tmpdir' for Dir"
  fails "RSpec::Core::Formatters::DeprecationFormatter#deprecation_summary with a File deprecation_stream pluralizes the reported deprecation count for more than one deprecation",  "undefined method `tmpdir' for Dir"
  fails "RSpec::Core::Formatters::DeprecationFormatter#deprecation_summary with a File deprecation_stream is not printed when there are no deprecations",  "undefined method `tmpdir' for Dir"
  fails "RSpec::Core::Formatters::DeprecationFormatter#deprecation_summary with a File deprecation_stream uses synchronized/non-buffered output to work around odd duplicate output behavior we have observed",  "undefined method `tmpdir' for Dir"
  fails "RSpec::Core::Formatters::DeprecationFormatter#deprecation_summary with a File deprecation_stream does not print duplicate messages",  "undefined method `tmpdir' for Dir"

  fails "RSpec::Core::Formatters::ProgressFormatter produces the expected full output",  "String#gsub! not supported. Mutable String methods are not supported in Opal."

  fails "RSpec::Core::Formatters::DocumentationFormatter produces the expected full output",  "String#gsub! not supported. Mutable String methods are not supported in Opal."

  fails "RSpec loads mocks and expectations when the constants are referenced",  "undefined method `run_ruby_with_current_load_path' for #<RSpec::ExampleGroups::RSpec:0x34620>"
  fails "RSpec::Core.path_to_executable returns the absolute location of the exe/rspec file",  "expected: truthy value"

end
