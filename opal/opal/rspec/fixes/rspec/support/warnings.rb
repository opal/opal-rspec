module ::RSpec::Support::Warnings
  def warn_with(message, options={})
    call_site = options.fetch(:call_site) { CallerFilter.first_non_rspec_line }
    # mutable strings
    # message << " Use #{options[:replacement]} instead." if options[:replacement]
    message += " Use #{options[:replacement]} instead." if options[:replacement]
    # message << " Called from #{call_site}." if call_site
    message += " Called from #{call_site}." if call_site
    ::Kernel.warn message
  end
end
