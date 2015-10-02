# Usage: `rake generate_requires`

require 'json'

# Opal will not have the built-in RNG, which affects the required outcome
Object.send(:remove_const, :Random)

# These scripts allow a leaner top level spec (like noted here)
BASE_FILES = %w{rspec rspec/mocks rspec/expectations rspec/core rspec/core/mocking_adapters/rspec}
FORMATTERS = %w{base_formatter base_text_formatter progress_formatter documentation_formatter html_printer}.map {|f| "rspec/core/formatters/#{f}"}
MATCHERS = %w{rspec/matchers/built_in/contain_exactly}
MOCK_STUFF = %w{matchers/expectation_customization any_instance}.map { |f| "rspec/mocks/#{f}" }
REQUIRES = BASE_FILES + FORMATTERS + MATCHERS + MOCK_STUFF

# Should not need to edit below this

ROOTS = Dir[__dir__+'/../rspec{,-{core,expectations,mocks,support}}/lib'].map {|root| File.expand_path(root)}
ROOTS_REGEXP = /\A(#{ROOTS.map {|r| Regexp.escape r}.join('|')})\//

module Kernel
  alias :orig_require :require
  def require path
    result = orig_require(path)
    puts "requiring: #{path} (#{result})"
    RSPEC_PATHS << path
    result
  end

  alias :orig_require_relative :require_relative
  def require_relative path
    base = File.dirname(caller(1,1).first)
    path_for_require = File.expand_path(path, base).sub(ROOTS_REGEXP, '')
    require path_for_require
  end
end

RSPEC_PATHS = []
REQUIRES.each {|r| require r }

# Put top level items first
requires = RSPEC_PATHS.uniq.sort

File.open 'opal/opal/rspec/requires.rb', 'w' do |file|
  file << "# Generated automatically by util/normalize_requires.rb, triggered by Rake task :generate_requires, do not edit\n"
  file << requires.map { |p| "require '#{p}'" }.join("\n")
end
