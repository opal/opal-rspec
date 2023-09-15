require 'spec_helper'

RSpec.describe 'Opal Specs' do
  shared_examples 'run_opal_spec' do |path, expected_output|
    it "successfully runs #{path}" do
      output = "#{__dir__}/../../tmp/#{path.hash}-#{$$}.txt"
      FileUtils.mkdir_p File.dirname(output)
      result = system("exe/opal-rspec", path, [:out, :err]=>[output, "w"])
      expect(File.read(output)).to include(expected_output)
      expect(result).to eq(true)
    end
  end

  describe 'spec-opal-passing/' do
    include_examples 'run_opal_spec', 'spec-opal-passing', "3 examples, 0 failures, 1 pending"
  end

  describe 'spec-opal-passing/tautology_spec.rb' do
    include_examples 'run_opal_spec', 'spec-opal-passing/tautology_spec.rb', "3 examples, 0 failures, 1 pending"
  end

  describe 'spec-opal-passing/tautology_spec.rb:8' do
    include_examples 'run_opal_spec', 'spec-opal-passing/tautology_spec.rb:8', "1 example, 0 failures"
  end

  describe 'spec-opal-passing/tautology_spec.rb[1:1]' do
    include_examples 'run_opal_spec', 'spec-opal-passing/tautology_spec.rb[1:1]', "1 example, 0 failures"
  end

  context 'as a whole' do

    attr_reader :test_output, :test_status

    def remove_colors(string)
      string.gsub(/\x1b\[[0-9\;]*m/, '')
    end

    before :all do
      `rake spec:opal >/tmp/spec-opal-output`
      @test_status = $?
      @test_output = remove_colors(File.read('/tmp/spec-opal-output'))
    end

    it "exists with status != 0 due to failed tests" do
      expect(test_status).not_to be_success
    end

    context 'has a summary line' do
      subject { test_output }

      it { is_expected.to match(/(\d+) examples, (\d+) failures, (\d+) pending/) }

      it 'with correct values' do
        examples, failures, pending = subject.scan(/(\d+) examples, (\d+) failures, (\d+) pending/).first
        expect([examples, failures, pending]).to eq(["136", "26", "11"])
      end
    end

    it 'has the expected failures' do
      actual_failures = test_output.scan(/^rspec .*?:[0-9]+ # (.*)$/).map(&:first).sort

      unexpected_failures = actual_failures.grep_v(/fail/)

      expect(unexpected_failures).to be_empty
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
