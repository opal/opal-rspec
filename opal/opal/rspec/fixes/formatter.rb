class RSpec::Core::Formatters::DeprecationFormatter
  # mutable strings not supported
  SpecifiedDeprecationMessage = Struct.new(:type) do
    def initialize(data)
      @message = data.message
      super deprecation_type_for(data)
    end

    def to_s
      output_formatted @message
    end

    def too_many_warnings_message
      "Too many similar deprecation messages reported, disregarding further reports. " + DEPRECATION_STREAM_NOTICE      
    end

    private

    def output_formatted(str)
      return str unless str.lines.count > 1
      separator = "#{'-' * 80}"
      "#{separator}\n#{str.chomp}\n#{separator}"
    end

    def deprecation_type_for(data)
      data.message.gsub(/(\w+\/)+\w+\.rb:\d+/, '')
    end
  end

  GeneratedDeprecationMessage = Struct.new(:type) do
    def initialize(data)
      @data = data
      super data.deprecated
    end

    def to_s
      msg =  "#{@data.deprecated} is deprecated."
      msg = msg + " Use #{@data.replacement} instead." if @data.replacement
      msg = msg + " Called from #{@data.call_site}." if @data.call_site
      msg
    end

    def too_many_warnings_message
      "Too many uses of deprecated '#{type}'. " + DEPRECATION_STREAM_NOTICE
    end
  end
end
