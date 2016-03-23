class RSpec::Core::Formatters::ExceptionPresenter
  def fully_formatted(failure_number, colorizer=::RSpec::Core::Formatters::ConsoleCodes)
    lines = fully_formatted_lines(failure_number, colorizer)
    # Opal/mutable strings
    # lines.join("\n") << "\n"
    lines.join("\n") + "\n"
  end
end
