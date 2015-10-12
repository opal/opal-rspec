unless Opal::RSpec::Compatibility.multiple_module_include_super_works_right?
  module ::RSpec::Mocks::VerifyingDouble
    def method_missing(message, *args, &block)
      # Null object conditional is an optimization. If not a null object,
      # validity of method expectations will have been checked at definition
      # time.
      if null_object?
        if @__sending_message == message
          __mock_proxy.ensure_implemented(message)
        else
          __mock_proxy.ensure_publicly_implemented(message, self)
        end
      end

      call_method_missing message, *args, &block
    end
  end
end
