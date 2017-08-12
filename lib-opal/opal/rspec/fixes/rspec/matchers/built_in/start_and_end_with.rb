module ::RSpec::Matchers::BuiltIn
  class StartAndEndWith
    def failure_message
      msg = super
      if @actual_does_not_have_ordered_elements
        msg += ", but it does not have ordered elements"
      elsif !actual.respond_to?(:[])
        msg += ", but it cannot be indexed using #[]"
      end
      msg
      # string mutation
      # super.tap do |msg|
      #   if @actual_does_not_have_ordered_elements
      #     msg << ", but it does not have ordered elements"
      #   elsif !actual.respond_to?(:[])
      #     msg << ", but it cannot be indexed using #[]"
      #   end
      # end
    end
  end
end
