class Encoding::UndefinedConversionError < StandardError; end unless defined? Encoding::UndefinedConversionError
class Encoding::InvalidByteSequenceError < StandardError; end unless defined? Encoding::InvalidByteSequenceError
class Encoding::ConverterNotFoundError < StandardError; end unless defined? Encoding::ConverterNotFoundError

# Opal doesn't support encoding
class RSpec::Support::EncodedString
  def <<(string)
    @string += matching_encoding(string)
  end

  def self.pick_encoding(source_a, source_b)
    "utf-8"
  end
end
