module OpalFilters
  extend self

  # class FiltersFormatter < RSpec::Core::Formatters::BaseFormatter
    # RSpec::Core::Formatters.register self, :dump_summary
  ::RSpec::Core::Notifications::SummaryNotification.class_eval do
    def colorized_rerun_commands(colorizer=::RSpec::Core::Formatters::ConsoleCodes)
      "\nFilter failed examples:\n\n" +
      failed_examples.map do |example|
        colorizer.wrap("fails #{example.full_description.inspect}, ", RSpec.configuration.failure_color) + " " +
        colorizer.wrap("#{example.execution_result.exception.message.strip.split("\n").first[0..100].inspect}", RSpec.configuration.detail_color)
      end.join("\n")
    end
  end

  def group(name, &block)
    old_name = @name
    @name = name
    @filters ||= {}
    instance_eval(&block)
    @name = old_name
  end

  def fails full_description, note = nil
    note = "#{name}: #{note || FIXME}"
    @filters[full_description] = note || full_description
  end

  def filtered?(example)
    @filters[example.full_description]
  end

  def pending_message(example)
    note = @filters[example.full_description]
    "#{@name}: #{note}"
  end
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
  fails "RSpec::Core::Example#pending in before(:all) fails with an ArgumentError if a block is provided",  "undefined method `deprecate' for RSpec"
  fails "RSpec::Core::Example#skip in the example with a message sets the example to skipped with the provided message",  "undefined method `deprecate' for RSpec"
  fails "RSpec::Core::Example#skip in before(:all) sets each example to pending",  "undefined method `deprecate' for RSpec"

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
  # fails "RSpec::Core::Formatters::BaseTextFormatter when closing the formatter does not close an already closed output stream",  "undefined method `mktmpdir' for Dir"
  fails "RSpec::Core::Formatters::BaseTextFormatter#dump_summary includes command to re-run each failed example",  "expected \"\\nFinished in 1 second (files took 0 seconds to load)\\n1 example, 1 failure\\n\\nFilter faile"
  fails "RSpec::Core::Formatters::BaseTextFormatter#dump_failures with an exception that has a differently encoded message runs without encountering an encoding exception",  "expected \"\\nFailures:\\n\\n  1) group name Mixing encodings, e.g. UTF-8: © and Binary\\n     Failure/Err"
  fails "RSpec::Core::Formatters::BaseTextFormatter#dump_failures with a failed expectation (rspec-expectations) does not show the error class",  "expected \"\\nFailures:\\n\\n  1) group name example name\\n     Failure/Error: Unable to find matching li"
  fails "RSpec::Core::Formatters::BaseTextFormatter#dump_failures with a failed message expectation (rspec-mocks) does not show the error class",  "expected \"\\nFailures:\\n\\n  1) group name example name\\n     Failure/Error: Unable to find matching li"
  fails "RSpec::Core::Formatters::BaseTextFormatter#dump_failures for #shared_examples outputs the name and location",  "expected \"\\nFailures:\\n\\n  1) group name it should behave like foo bar example name\\n     Failure/Err"
  fails "RSpec::Core::Formatters::BaseTextFormatter#dump_failures for #shared_examples that contains nested example groups outputs the name and location",  "expected \"\\nFailures:\\n\\n  1) group name it should behave like foo bar nested group example name\\n   "
end

RSpec.configure do |config|
  # config.filter_run_excluding :full_description => Regexp.union(expected_failures.map { |d| Regexp.new(d) })
  # config.filter_run_excluding :full_description => -> desc { unsupported.include? desc }
  config.before(:each) do |example|
    pending OpalFilters.pending_message(example) if OpalFilters.filtered?(example)
  end

  # config.add_formatter OpalFilters::FiltersFormatter, $stdout
end


# def Dir.tmpdir(prefix_suffix=nil, tmpdir=nil, *rest)
#   `require('os').tmpdir()`
# end
#
# require 'fileutils'
# module FileUtils
#   extend self
#   def remove_entry(path, force = false)
#     `require('fs').rmdirSync(path)`
#   end
# end
#
# def Dir.mktmpdir(prefix_suffix=nil, tmpdir=nil, *rest)
#   tmpdir ||= Dir.tmpdir
#   case prefix_suffix
#   when String
#     prefix = prefix_suffix
#   when Array
#     prefix, suffix = prefix_suffix
#   else
#     prefix = 'd'
#   end
#
#   rand_name = rand.to_s[2..-1]
#   name = "#{prefix}#{rand_name}#{suffix}"
#   path = File.join(tmpdir, name)
#   Dir.mkdir(path)
#
#   if block_given?
#     begin
#       yield path
#     ensure
#       # stat = File.stat(File.dirname(path))
#       # if stat.world_writable? and !stat.sticky?
#       #   raise ArgumentError, "parent directory is world writable but not sticky"
#       # end
#       FileUtils.remove_entry path
#     end
#   else
#     path
#   end
# end
#
# class File
#   def rewind
#
#   end
# end
