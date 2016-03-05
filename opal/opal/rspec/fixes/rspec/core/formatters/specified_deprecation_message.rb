RSpec::Core::Formatters::DeprecationFormatter::SpecifiedDeprecationMessage.class_eval do
  def too_many_warnings_message
    # mutable strings not supported
    "Too many similar deprecation messages reported, disregarding further reports. " + DEPRECATION_STREAM_NOTICE
  end
end

