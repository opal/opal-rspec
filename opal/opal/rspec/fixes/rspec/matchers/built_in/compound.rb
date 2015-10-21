class ::RSpec::Matchers::BuiltIn::Compound
  def multiline_message(message_1, message_2)
    # \z and \A not supported in Opal
    # [
    #     indent_multiline_message(message_1.sub(/\n+\z/, '')),
    #     "...#{conjunction}:",
    #     indent_multiline_message(message_2.sub(/\A\n+/, ''))
    # ].join("\n\n")
    [
        indent_multiline_message(message_1.sub(/\n+$/, '')),
        "...#{conjunction}:",
        indent_multiline_message(message_2.sub(/^\n+/, ''))
    ].join("\n\n")
  end
end
