module RSpec
  module Mocks
    # @private
    class Proxy
      def ensure_can_be_proxied!(object)
        return unless object.is_a?(Symbol) || object.frozen?
        return if object.nil?

        msg = "Cannot proxy frozen objects"
        if Symbol === object
          msg += ". Symbols such as #{object} cannot be mocked or stubbed."
        else
          msg += ", rspec-mocks relies on proxies for method stubbing and expectations."
        end
        raise ArgumentError, msg
      end
    end
  end
end
