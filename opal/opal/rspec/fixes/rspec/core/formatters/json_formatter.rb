class ::RSpec::Core::Formatters::JsonFormatter
  def close(_notification)
    output.write @output_hash.to_json
    # JSON formatter does not look @ closed? and we need it to, otherwise Phantom freezes
    return unless IO === output
    return if output.closed? || output == $stdout

    output.close
  end
end
