module RSpec
  module Mocks
    # Contains methods intended to be used from within code examples.
    # Mix this in to your test context (such as a test framework base class)
    # to use rspec-mocks with your test framework. If you're using rspec-core,
    # it'll take care of doing this for you.
    module ExampleMethods
      # Don't hide the Float... Opal breaks then
      def hide_const(constant_name)
        ConstantMutator.hide(constant_name) unless constant_name == "Float"
      end
    end
  end
end
