unless Opal::RSpec::Compatibility.multiple_module_include_super_works_right?
  module ::RSpec::Mocks::TestDouble
    # With multiple modules included in a class, Opal doesn't let module 2 (VerifyingDouble) invoke super from module 1 (TestDouble)
    def call_method_missing(message, *args, &block)
      proxy = __mock_proxy
      proxy.record_message_received(message, *args, &block)

      if proxy.null_object?
        case message
          when :to_int then
            return 0
          when :to_a, :to_ary then
            return nil
          when :to_str then
            return to_s
          else
            return self
        end
      end

      # Defined private and protected methods will still trigger `method_missing`
      # when called publicly. We want ruby's method visibility error to get raised,
      # so we simply delegate to `super` in that case.
      # ...well, we would delegate to `super`, but there's a JRuby
      # bug, so we raise our own visibility error instead:
      # https://github.com/jruby/jruby/issues/1398
      visibility = proxy.visibility_for(message)
      if visibility == :private || visibility == :protected
        ErrorGenerator.new(self, @name).raise_non_public_error(
            message, visibility
        )
      end

      # Required wrapping doubles in an Array on Ruby 1.9.2
      raise NoMethodError if [:to_a, :to_ary].include? message
      proxy.raise_unexpected_message_error(message, *args)
    end
  end
end
