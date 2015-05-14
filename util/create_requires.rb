require 'json'

# Opal will not have the built-in RNG
Object.send(:remove_const, :Random)

FORMATTERS = %w{base_text_formatter html_printer progress_formatter}
REQUIRES = %w{rspec rspec/mocks rspec/expectations rspec/core} + FORMATTERS.map {|f| "rspec/core/formatters/#{f}"}

# Should not need to edit below this

alias :orig_require :require

module RequireCreation
  PATHS = []
end

def require s
  RequireCreation::PATHS << s if orig_require(s)
end

alias :orig_require_relative :require_relative
def require_relative s
  # Relative won't function normally without normal gem usage (using submodules here)
  guesses = [s, "rspec/#{s}"]
  use = guesses.find do |g|
      begin
        orig_require g
        true
      rescue LoadError
        false
      end
  end
  raise "Unable to find dependency #{s}, guessed with #{guesses}" unless use
  RequireCreation::PATHS << use
end

REQUIRES.each {|r| require r }

File.open 'opal/opal/rspec/requires.rb', 'w' do |file|
  file << JSON.dump(RequireCreation::PATHS.uniq)
end
