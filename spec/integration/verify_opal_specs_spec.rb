require 'spec_helper'

RSpec.describe 'Opal Specs' do
  context 'as a whole' do

    attr_reader :test_output, :test_status

    def remove_colors(string)
      string.gsub(/\x1b\[[0-9\;]*m/, '')
    end

    before :all do
      @test_output = remove_colors(`rake spec:opal 1> /dev/stdout 2> /dev/null`.force_encoding('UTF-8'))
      @test_status = $?
    end

    it "exists with status != 0 due to failed tests" do
      expect(test_status).not_to be_success
    end

    it 'has a summary line' do
      expect(test_output).to match(/(\d+) examples, (\d+) failures, (\d+) pending/)
      examples, failures, pending = test_output.scan(/(\d+) examples, (\d+) failures, (\d+) pending/).first
      expect(examples).to eq('158')
      expect(failures).to eq('13')
      expect(pending ).to eq('9')
    end

    it 'has the expected failures' do
      # subject sync unnamed assertion fails properly should eq 43
      # subject sync unnamed fails properly during subject create
      # subject async assertion implicit fails properly should eq 43
      # subject async fails properly during creation explicit async
      # subject async fails properly during creation implicit usage
      # subject async assertion explicit async fails properly
      # hooks around sync fails after example should equal 42
      # hooks around sync fails before example
      # hooks before async with async subject async match fails properly
      # hooks before async with async subject before :each fails properly should not reach the example
      # hooks before async with async subject before :each succeeds, assertion fails properly should not eq 42
      # hooks before async with async subject before :each succeeds, subject fails properly should not reach the example
      # hooks before async with async subject both subject and before(:each) fail properly should not reach the example
      # hooks before async with sync subject async match fails properly
      # hooks before async with sync subject before :each fails properly should not reach the example
      # hooks before async with sync subject match fails properly should not eq 42
      # hooks before sync with sync subject context fails properly should not reach the example
      # hooks before sync with sync subject before :each fails properly should not reach the example
      # hooks before sync with sync subject match fails properly should not eq 42
      # hooks before sync with sync subject first before :each in chain triggers failure inner context should not reach the example
      # hooks after sync after fails should eq 42
      # hooks after sync before fails should not reach the example
      # hooks after sync match fails async match
      # hooks after sync match fails sync match should eq 43
      # hooks after async after(:each) fails properly
      # hooks after async before(:each) fails properly
      # hooks after async match fails properly async match
      # hooks after async match fails properly sync match should eq 43
      expected_failures = %[
        promise should make example fail properly before async block reached
        promise matcher fails properly
        promise non-assertion failure in promise no args
        promise non-assertion failure in promise string arg
        promise non-assertion failure in promise exception arg
        pending in example no promise would not fail otherwise, thus fails properly FIXED
        async/sync mix fails properly if a sync test is among async tests
        async/sync mix can finish running after a long delay and fail properly
        be_truthy fails properly with truthy values
        exception handling should fail properly if an exception is raised
        exception handling should ignore an exception after a failed assertion
      ].strip.split("\n").map(&:strip).sort

      actual_failures = test_output.scan(/\d+\) (.*)/).map(&:first).sort

      expect(actual_failures).to include(expected_failures)
    end

    # it 'has some expected errors' do
    #   expect(test_output).to match(/.*is still running, after block problem.*/)
    #   expect(test_output).to match(/.*should not have.*/)
    #   expect(test_output).to match(/.*Expected \d+ after hits but got \d+.*/)
    #   expect(test_output).to match(/.*Expected \d+ around hits but got \d+.*/)
    # end
  end

  # context 'by file' do
  #   context 'after_hooks_spec' do
  #     attr_reader :test_output, :test_status
  #
  #     before :all do
  #       @test_output = `rake spec:opal PATTERN=spec-opal/after_hooks_spec.rb`.force_encoding('UTF-8')
  #       @test_status = $?
  #     end
  #
  #     it 'does something' do
  #       expect(test_output).to include(%{
  #         Run options: include {"focus"=>true}
  #
  #         All examples were filtered out; ignoring {"focus"=>true}
  #         F*.FFF.
  #         An error occurred in an `after(:context)` hook.
  #           RuntimeError: it failed in the after context!
  #           occurred at RuntimeError: it failed in the after context!
  #
  #         ******Expected 13 after hits but got 6
  #
  #
  #         Pending:
  #           hooks after sync match succeeds async match
  #             # Temporarily skipped with xit
  #             #
  #           hooks after async before(:each) fails properly
  #             # Temporarily skipped with xcontext
  #             #
  #           hooks after async match succeeds async match
  #             # Temporarily skipped with xcontext
  #             #
  #           hooks after async match succeeds sync match
  #             # Temporarily skipped with xcontext
  #             #
  #           hooks after async match fails properly async match
  #             # Temporarily skipped with xcontext
  #             #
  #           hooks after async match fails properly sync match
  #             # Temporarily skipped with xcontext
  #             #
  #           hooks after async after(:each) fails properly
  #             # Temporarily skipped with xcontext
  #             #
  #
  #         Failures:
  #
  #           1) hooks after sync before fails should not reach the example
  #              Failure/Error: Unable to find matching line from backtrace
  #              RuntimeError:
  #                before problem
  #              #     at Object.TMP_6 (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:59751:16)
  #              #     at Object.$$instance_exec [as $instance_exec] (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:3715:24)
  #              #     at Opal.send (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:1581:23)
  #              #     at $Example.$$instance_exec [as $instance_exec] (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:28507:18)
  #              #     at Opal.send (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:1581:23)
  #              #     at $BeforeHook.$$run [as $run] (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:32540:20)
  #              #     at TMP_21 (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:32689:22)
  #              #     at Object.Opal.yield1 (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:1362:14)
  #              #     at Array.$$each [as $each] (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:12559:26)
  #              #     at Opal.send (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:1581:23)
  #              #
  #              #   Showing full backtrace because every line was filtered out.
  #              #   See docs for RSpec::Configuration#backtrace_exclusion_patterns and
  #              #   RSpec::Configuration#backtrace_inclusion_patterns for more information.
  #
  #           2) hooks after sync match fails async match
  #              Failure/Error: Unable to find matching line from backtrace
  #              NoMethodError:
  #                undefined method `delay_with_promise' for #<RSpec::ExampleGroups::Hooks::After::Sync::MatchFails:0x9b6>
  #              # delay_with_promise: undefined method `delay_with_promise' for #<RSpec::ExampleGroups::Hooks::After::Sync::MatchFails:0x9b6>
  #              #
  #              #   Showing full backtrace because every line was filtered out.
  #              #   See docs for RSpec::Configuration#backtrace_exclusion_patterns and
  #              #   RSpec::Configuration#backtrace_inclusion_patterns for more information.
  #
  #           3) hooks after sync match fails sync match should eq 43
  #              Failure/Error: Unable to find matching line from backtrace
  #
  #                expected: 43
  #                     got: 42
  #
  #                (compared using ==)
  #              # ExpectationNotMetError:
  #              #     at module_constructor.$$fail_with [as $fail_with] (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:58404:17)
  #              #     at module_constructor.$$handle_failure [as $handle_failure] (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:39027:102)
  #              #     at singleton_class_alloc.$$handle_matcher [as $handle_matcher] (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:39054:183)
  #              #     at Opal.send (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:1581:23)
  #              #     at $ExpectationTarget.$$to [as $to] (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:38784:18)
  #              #     at Object.TMP_21 (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:59865:40)
  #              #     at Object.$$instance_exec [as $instance_exec] (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:3715:24)
  #              #     at Opal.send (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:1581:23)
  #              #     at /private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:28263:19
  #              #
  #              #   Showing full backtrace because every line was filtered out.
  #              #   See docs for RSpec::Configuration#backtrace_exclusion_patterns and
  #              #   RSpec::Configuration#backtrace_inclusion_patterns for more information.
  #
  #           4) hooks after sync after fails should eq 42
  #              Failure/Error: Unable to find matching line from backtrace
  #              RuntimeError:
  #                expected after problem
  #              #     at Object.TMP_9 (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:59781:25)
  #              #     at Object.$$instance_exec [as $instance_exec] (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:3715:24)
  #              #     at Opal.send (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:1581:23)
  #              #     at $Example.$$instance_exec_with_rescue [as $instance_exec_with_rescue] (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:28487:20)
  #              #     at Opal.send (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:1581:23)
  #              #     at $AfterHook.$$run [as $run] (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:32553:20)
  #              #     at TMP_21 (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:32689:22)
  #              #     at Object.Opal.yield1 (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:1362:14)
  #              #     at Array.$$each [as $each] (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:12559:26)
  #              #     at Opal.send (/private/var/folders/w0/yjfqr9n94ld7ft4j3hlz_fsm0000gn/T/opal-nodejs-runner-20170822-32491-vfi1gh:1581:23)
  #              #
  #              #   Showing full backtrace because every line was filtered out.
  #              #   See docs for RSpec::Configuration#backtrace_exclusion_patterns and
  #              #   RSpec::Configuration#backtrace_inclusion_patterns for more information.
  #
  #         Finished in 0.12 seconds (files took 0.461 seconds to load)
  #         13 examples, 4 failures, 7 pending
  #
  #         Failed examples:
  #
  #         rspec  # hooks after sync before fails should not reach the example
  #         rspec  # hooks after sync match fails async match
  #         rspec  # hooks after sync match fails sync match should eq 43
  #         rspec  # hooks after sync after fails should eq 42
  #         rake aborted!
  #       }.gsub(/^          /, ''))
  #     end
  #
  #   end
  # end
end
