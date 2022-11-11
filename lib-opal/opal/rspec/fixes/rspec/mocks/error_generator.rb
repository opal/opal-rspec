module RSpec
  module Mocks
    class ErrorGenerator
      # mutable strings
      def error_message(expectation, args_for_multiple_calls)
        expected_args = format_args(expectation.expected_args)
        actual_args = format_received_args(args_for_multiple_calls)

        if RSpec::Support::RubyFeatures.distincts_kw_args_from_positional_hash? && expected_args == actual_args
          expected_hash = expectation.expected_args.last
          actual_hash = args_for_multiple_calls.last.last
          if Hash === expected_hash && Hash === actual_hash &&
            (Hash.ruby2_keywords_hash?(expected_hash) != Hash.ruby2_keywords_hash?(actual_hash))
            actual_args += Hash.ruby2_keywords_hash?(actual_hash) ? " (keyword arguments)" : " (options hash)"
            expected_args += Hash.ruby2_keywords_hash?(expected_hash) ? " (keyword arguments)" : " (options hash)"
          end
        end

        message = default_error_message(expectation, expected_args, actual_args)

        if args_for_multiple_calls.one?
          diff = diff_message(expectation.expected_args, args_for_multiple_calls.first)
          message += "\nDiff:#{diff}" unless diff.strip.empty?
        end

        message
      end
    end
  end
end
