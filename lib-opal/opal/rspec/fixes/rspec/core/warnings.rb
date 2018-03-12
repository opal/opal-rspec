# not 100% sure this compat check fixes this, but it's pretty close
unless Opal::RSpec::Compatibility.multiple_module_include_super_works_right?
  require 'opal/rspec/fixes/rspec/support/warnings'

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
      # let's inline the method
      call_site = options.fetch(:call_site) { ::RSpec::CallerFilter.first_non_rspec_line }
      # mutable strings
      # message << " Use #{options[:replacement]} instead." if options[:replacement]
      message += " Use #{options[:replacement]} instead." if options[:replacement]
      # message << " Called from #{call_site}." if call_site
      message += " Called from #{call_site}." if call_site
      ::Kernel.warn message
    end
  end
end
