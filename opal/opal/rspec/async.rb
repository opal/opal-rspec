module Opal
  module RSpec
    # {AsyncHelpers} is automatically included in all example groups to add
    # support for running specs async. Usually, rspec runners expect all
    # examples to run synchronously, but this is not ideal in the case for
    # Opal where a lot of underlying libraries expect the ability to run code
    # in an asynchronous manner.
    #
    # This module defines an {AsyncHelpers::ClassMethods.async} method which
    # can be used instead of `it` inside an example group, which marks the
    # example as being async. This makes the runner wait for the example to
    # complete.
    #
    #     describe "Some examples" do
    #       it "normal example" do
    #         # normal test code
    #       end
    #
    #       async "async example" do
    #         # this will wait until completion before moving on
    #       end
    #     end
    #
    # Marking an example as being async is only half the task. Examples will
    # also have an instance {AsyncHelpers#async} method defined which is then
    # used to complete the example. Any code run inside this block will run
    # inside the context of the example.
    #
    #     describe "HTTP requests" do
    #       async "might take a while" do
    #         HTTP.get("/url/to/get") do |res|
    #           async { expect(res).to be_ok }
    #         end
    #       end
    #     end
    #
    # As soon as `async` is run inside the block, the example completes. This
    # means that only 1 `async` call is allowed. However, you can use `async`
    # multiple times aslong as it is only called once:
    #
    #     describe "HTTP requests" do
    #       async "should work" do
    #         HTTP.get("/users/1").then |res|
    #           async { expect(res).to be_ok }
    #         end.fail do
    #           async { raise "this should not be called" }
    #         end
    #       end
    #     end
    #
    # Here, a promise will either be accepted or rejected, so an `async` block
    # can be used in each case as only 1 will be called.
    #
    # Another helper, {AsyncHelpers#delay} can also be used to run a block of
    # code after a given time in seconds. This is useful to wait for animations
    # or time restricted operations to occur.
    module AsyncHelpers
      module ClassMethods
        # Define an async example method. This should be used instead of `it`
        # to inform the spec runner that the example will need to wait for an
        # {AsyncHelpers#async} method to complete the test. Any additional
        # configuration options can be passed to this call, and they just get
        # delegated to the underlying `#it` call.
        #
        # @example
        #   describe "Some tests" do
        #     async "should be async" do
        #       # ... async code
        #     end
        #
        #     it "should work with normal tests" do
        #       expect(1).to eq(1)
        #     end
        #   end
        #
        # @param desc [String] description
        def async(desc, *args, &block)
          options = ::RSpec::Core::Metadata.build_hash_from(args)
          Opal::RSpec::AsyncExample.register(self, desc, options, block)
        end
      end

      def self.included(base)
        base.extend ClassMethods
      end

      # Must be used with {ClassMethods#async} to finish the async action. If
      # this is not called inside the body then the spec runner will time out
      # or the error might give a false positive as it is not caught inside
      # the current example.
      #
      # @example Complete expectation after HTTP request
      #   describe "HTTP calls" do
      #     async "complete eventually" do
      #       HTTP.get("/some_url") do |response|
      #         async { expect(response).to be_ok }
      #       end
      #     end
      #   end
      #
      def async(&block)        
        # we may have timed out, in which case @example will be gone
        @example.continue_async(block) if @example
      end

      # Runs the given block after a given duration. You are still required to
      # use a {#async} block inside the delayed callback. This helper can be
      # used to simulate IO delays, or just to wait for animations/other
      # behaviour to finish.
      #
      # The `duaration` should be given in seconds, i.e. `1` means 1 second, or
      # 0.3 means 300ms. The given block is just run after the time delay.
      #
      # @example
      #   describe "Some interaction" do
      #     async "takes a while to complete" do
      #       task = start_long_task!
      #
      #       delay(1) do
      #         async { expect(task).to be_completed }
      #       end
      #     end
      #   end
      #
      # @param duration [Integer, Float] time in seconds to wait
      def delay(duration, &block)
        `setTimeout(block, duration * 1000)`
        self
      end

      # Use {#async} instead.
      #
      # @deprecated
      def run_async(&block)
        async(&block)
      end

      # Use {#delay} instead.
      #
      # @deprecated
      def set_timeout(*args, &block)
        delay(*args, &block)
      end
    end

    # Runs all async examples from {AsyncExample.examples}.
    class AsyncRunner
      def initialize(runner, reporter, finish_block)
        @runner = runner
        @reporter = reporter
        @finish_block = finish_block
      end

      def run
        @examples = AsyncExample.examples.clone
        run_next_example
      end

      def run_next_example
        if @examples.empty?
          finish
        else
          run_example @examples.pop
        end
      end

      def run_example(example)
        example_group = example.example_group

        @reporter.example_group_started example_group
        instance = example_group.new

        example.run(instance, @reporter) do
          example_finished example
        end
      end

      def example_finished(example)
        @reporter.example_group_finished example.example_group
        run_next_example
      end

      # Called once all examples have finished. Just calls back to main
      # runner to inform it
      def finish
        @finish_block.call
      end
    end

    # An {AsyncExample} is a subclass of regular example instances which adds
    # support for running an example, and waiting for a non-sync outcome. All
    # async examples in a set of spec files will get registered through
    # {AsyncExample.register}, and added to the {AsyncExample.examples} array
    # ready for the runner to run.
    #
    # You will not need to create new instances of this class directly, and
    # should instead use {AsyncHelpers} to create async examples.
    class AsyncExample < ::RSpec::Core::Example
      include AsyncHelpers

      # Register new async example.
      #
      # @see AsyncHelpers::ClassMethods.async
      def self.register(*args)
        group = args[0]
        group.examples << new(*args)
      end

      # All async examples in specs.
      #
      # @return [Array<AsyncExample>]
      def self.examples
        @examples ||= []
      end

      def run(example_group_instance, reporter)
        @example_group_instance = example_group_instance
        @reporter               = reporter
        @finished               = false

        should_wait = true

        ::RSpec.current_example = self
        example_group_instance.instance_variable_set :@example, self

        start(reporter)

        begin
          run_before_example
          @example_group_instance.instance_exec(self, &@example_block)
          if pending?
            Pending.mark_fixed! self

            raise Pending::PendingExampleFixedError,
                  'Expected example to fail since it is pending, but it passed.',
                  [location]
          end
        rescue Exception => e
          set_exception(e)
          should_wait = false
        end

        if should_wait
          delay self.metadata[:timeout] || 10 do
            next if finished?

            set_exception RuntimeError.new("timeout")
            async_example_finished
          end
        else
          async_example_finished
        end
      end

      def continue_async(block)
        return if finished?

        begin
          block.call
        rescue Exception => e
          set_exception(e)
        end

        async_example_finished
      end

      def finished?
        @finished
      end

      def async_example_finished
        @finished = true

        begin
          run_after_example
        rescue Exception => e
          set_exception(e)
        ensure
          @example_group_instance.instance_variables.each do |ivar|
            @example_group_instance.instance_variable_set(ivar, nil)
          end
          @example_group_instance = nil

          begin
            assign_generated_description
          rescue Exception => e
            set_exception(e, "while assigning the example description")
          end
        end

        finish(@reporter)
        ::RSpec.current_example = nil
      end
    end
  end
end
