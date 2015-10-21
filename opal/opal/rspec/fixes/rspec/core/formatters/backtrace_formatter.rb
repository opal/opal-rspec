class ::RSpec::Core::BacktraceFormatter
  def backtrace_line(line)
    # don't have the Metadata class in Opal
    #Metadata.relative_path(line) unless exclude?(line)
    nil
  end

  alias_method :original_format_backtrace, :format_backtrace

  def format_backtrace(backtrace, options={})
    # Javascript stack traces include the message on the first few lines, but we already have that in the message
    # have several blank lines as well
    original_format_backtrace clean_js_backtrace(backtrace), options
  end

  def clean_js_backtrace(backtrace)
    valid_line = /\s*at.*/
    backtrace.select { |line| valid_line.match line }
  end
end
