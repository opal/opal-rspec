# Opal doesn't support encoding
class RSpec::Support::EncodedString
  def initialize(string, encoding=nil)
    @string = string
  end
  
  def to_s
    @string
  end
end
