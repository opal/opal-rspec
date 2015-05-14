require 'json'

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

# Opal will not have the built-in RNG
Object.send(:remove_const, :Random)
require 'rspec'
require 'rspec/mocks'
require 'rspec/expectations'

File.open 'opal/opal/rspec/requires.rb', 'w' do |file|
  file << JSON.dump(RequireCreation::PATHS)
end
