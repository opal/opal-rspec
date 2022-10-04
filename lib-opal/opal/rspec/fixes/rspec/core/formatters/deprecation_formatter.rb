class RSpec::Core::Formatters::DeprecationFormatter
  # GeneratedDeprecationMessage is a Struct
  GeneratedDeprecationMessage.class_eval do
    def to_s
      msg = String.new("#{@data.deprecated} is deprecated.")
      msg += " Use #{@data.replacement} instead." if @data.replacement
      msg += " Called from #{@data.call_site}."   if @data.call_site
      msg
    end
  end
end
