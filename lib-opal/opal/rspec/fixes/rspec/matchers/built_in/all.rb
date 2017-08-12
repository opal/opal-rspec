class ::RSpec::Matchers::BuiltIn::All
  def indent_multiline_message(message)
    # \z not supported in opal
    #message = message.sub(/\n+\z/, '')
    message = message.sub(/\n+$/, '')
    message.lines.map do |line|
      line =~ /\S/ ? '   ' + line : line
    end.join
  end
end
