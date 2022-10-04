# await: *await*

require 'rspec/core/hooks'

module RSpec
  module Core
    module Hooks
      class HookCollections
        def run_example_hooks_for_await(example, position, each_method)
          # WAS:
          # owner_parent_groups.__send__(each_method) do |group|
          #   group.hooks.run_owned_hooks_for(position, :example, example)
          # end
          case each_method
          when :each
            groups = owner_parent_groups
          when :reverse_each
            groups = owner_parent_groups.reverse
          else
            raise "Unsupported each_method: #{each_method}"
          end
          groups.each_await do |group|
            group.hooks.run_owned_hooks_for_await(position, :example, example)
          end
        end

        def run_owned_hooks_for_await(position, scope, example_or_group)
          # WAS:
          # matching_hooks_for(position, scope, example_or_group).each do |hook|
          #   hook.run(example_or_group)
          # end

          matching_hooks_for(position, scope, example_or_group).each_await do |hook|
            hook.run_await(example_or_group)
          end
        end

        def run_await(position, scope, example_or_group)
          return if RSpec.configuration.dry_run?

          if scope == :context
            unless example_or_group.class.metadata[:skip]
              run_owned_hooks_for_await(position, :context, example_or_group)
            end
          else
            case position
            when :before then run_example_hooks_for_await(example_or_group, :before, :reverse_each)
            when :after  then run_example_hooks_for_await(example_or_group, :after,  :each)
            when :around then run_around_example_hooks_for_await(example_or_group) { yield.await }
            end
          end
        end

        def run_around_example_hooks_for_await(example)
          hooks = FlatMap.flat_map(owner_parent_groups) do |group|
            group.hooks.matching_hooks_for(:around, :example, example)
          end

          return yield if hooks.empty? # exit early to avoid the extra allocation cost of `Example::Procsy`

          initial_procsy = Example::Procsy.new(example) { yield.await }
          hooks.inject(initial_procsy) do |procsy, around_hook|
            procsy.wrap { around_hook.execute_with_await(example, procsy) }
          end.call.await
        end
      end

      class BeforeHook < Hook
        def run_await(example)
          example.instance_exec_await(example, &block)
        end
      end

      # @private
      class AfterHook < Hook
        def run_await(example)
          example.instance_exec_await(example, &block)
        rescue Support::AllExceptionsExceptOnesWeMustNotRescue => ex
          example.set_exception(ex)
        end
      end

      # @private
      class AfterContextHook < Hook
        def run_await(example)
          example.instance_exec_await(example, &block)
        rescue Support::AllExceptionsExceptOnesWeMustNotRescue => e
          RSpec.configuration.reporter.notify_non_example_exception(e, "An error occurred in an `after(:context)` hook.")
        end
      end

      class AroundHook < Hook
        def execute_with_await(example, procsy)
          example.instance_exec_await(procsy, &block)
          return if procsy.executed?
          Pending.mark_skipped!(example,
                                "#{hook_description} did not execute the example")
        end
      end
    end
  end
end
