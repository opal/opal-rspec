unless Opal::RSpec::Compatibility.multiple_module_include_super_works_right?
  module Opal::RSpec::VerifyingDoubleFixes
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

  module ::RSpec::Mocks
    module VerifyingDouble
      include ::Opal::RSpec::VerifyingDoubleFixes
    end

    # In Opala 0.9, this also
    class ObjectVerifyingDouble
      include ::Opal::RSpec::VerifyingDoubleFixes
    end
  end
end
