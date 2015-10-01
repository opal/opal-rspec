class RSpec::Core::Formatters::DeprecationFormatter
  # SpecifiedDeprecationMessage is a Struct
  SpecifiedDeprecationMessage.define_method(:too_many_warnings_message) do
    # mutable strings not supported
    "Too many similar deprecation messages reported, disregarding further reports. " + DEPRECATION_STREAM_NOTICE
  end

  # GeneratedDeprecationMessage is a Struct
  GeneratedDeprecationMessage.define_method(:to_s) do
    msg = "#{@data.deprecated} is deprecated."
    msg = msg + " Use #{@data.replacement} instead." if @data.replacement
    msg = msg + " Called from #{@data.call_site}." if @data.call_site
    msg
  end
end
