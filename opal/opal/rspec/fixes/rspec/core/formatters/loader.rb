class ::RSpec::Core::Formatters::Loader
  def string_const?(str)
    # Incompatible regex (\A flag and \z flag)
    # str.is_a?(String) && /\A[A-Z][a-zA-Z0-9_:]*\z/ =~ str
    str.is_a?(String) && /^[A-Z][a-zA-Z0-9_:]*$/ =~ str
  end

  def underscore(camel_cased_word)
    # string mutation
    word = camel_cased_word.to_s.dup
    word = word.gsub(/::/, '/')
    word = word.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
    word = word.gsub(/([a-z\d])([A-Z])/, '\1_\2')
    word = word.tr("-", "_")
    word.downcase
  end

  def custom_formatter(formatter_ref)
    if Class === formatter_ref
      formatter_ref
    elsif string_const?(formatter_ref)
      while true
        begin
          return formatter_ref.gsub(/^::/, '').split('::').inject(Object) { |a, e| a.const_get e }
        rescue NameError
          # retry not supported on opal
          raise unless require(path_for(formatter_ref))
        end
      end
    end
  end
end

