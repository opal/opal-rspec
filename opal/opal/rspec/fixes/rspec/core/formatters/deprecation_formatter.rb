class RSpec::Core::Formatters::DeprecationFormatter

  # SpecifiedDeprecationMessage is a Struct
  SpecifiedDeprecationMessage.class_eval do
    def too_many_warnings_message
      # mutable strings not supported
      "Too many similar deprecation messages reported, disregarding further reports. " + DEPRECATION_STREAM_NOTICE
    end
  end

  # GeneratedDeprecationMessage is a Struct
  GeneratedDeprecationMessage.class_eval do
    def to_s
      msg = "#{@data.deprecated} is deprecated."
      msg = msg + " Use #{@data.replacement} instead." if @data.replacement
      msg = msg + " Called from #{@data.call_site}." if @data.call_site
      msg
    end
  end
end
