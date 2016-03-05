class ::RSpec::Matchers::BuiltIn::Compound
  def compound_failure_message
    # \z and \A not supported in Opal
    # "#{indent_multiline_message(matcher_1.failure_message.sub(/\n+\z/, ''))}" \
    # "\n\n...#{conjunction}:" \
    # "\n\n#{indent_multiline_message(matcher_2.failure_message.sub(/\A\n+/, ''))}
    "#{indent_multiline_message(matcher_1.failure_message.sub(/\n+$/, ''))}" + "\n\n...#{conjunction}:" + "\n\n#{indent_multiline_message(matcher_2.failure_message.sub(/^\n+/, ''))}"
  end
end
