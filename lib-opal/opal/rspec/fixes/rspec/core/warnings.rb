# not 100% sure this compat check fixes this, but it's pretty close
unless Opal::RSpec::Compatibility.multiple_module_include_super_works_right?
  module ::RSpec::Core::Warnings
    def warn_with(message, options={})
      if options[:use_spec_location_as_call_site]
        message += "." unless message.end_with?(".")

        if RSpec.current_example
          message += " Warning generated from spec at `#{RSpec.current_example.location}`."
        end
      end

      # super won't find this
      # super(message, options)
      support_warn_with message, options
    end
  end
end
