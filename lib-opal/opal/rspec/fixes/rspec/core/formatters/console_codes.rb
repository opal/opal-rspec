module ::RSpec::Core::Formatters::ConsoleCodes
  def wrap(text, code_or_symbol)
    if RSpec.configuration.color_enabled?
      # Need to escape the \e differently in JS and can't use string interpolation
      #"\e[#{console_code_for(code_or_symbol)}m#{text}\e[0m"
      "\033" + "[#{console_code_for(code_or_symbol)}m#{text}" +"\033" + '[0m'
    else
      text
    end
  end
end
