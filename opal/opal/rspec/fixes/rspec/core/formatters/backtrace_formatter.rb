class ::RSpec::Core::BacktraceFormatter
  def backtrace_line(line)
    # don't have the Metadata class in Opal
    #Metadata.relative_path(line) unless exclude?(line)
    nil
  end
end
