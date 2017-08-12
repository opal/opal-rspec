RSpec::Core::Formatters::DeprecationFormatter::GeneratedDeprecationMessage.class_eval do
  # string mutations
  def to_s
    msg = "#{@data.deprecated} is deprecated."
    msg += " Use #{@data.replacement} instead." if @data.replacement
    msg += " Called from #{@data.call_site}." if @data.call_site
    msg
  end

  def too_many_warnings_message
    msg = "Too many uses of deprecated '#{type}'. "
    msg += RSpec::Core::Formatters::DeprecationFormatter::DEPRECATION_STREAM_NOTICE
    msg
  end
end
