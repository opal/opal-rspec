# best guess for now, this is not defined by Opal, needed for instance_method_stasher.rb
RUBY_DESCRIPTION = RUBY_VERSION unless defined?(RUBY_DESCRIPTION)

class SecurityError < Exception; end unless defined?(SecurityError)

require_relative 'fixes/opal/compatibility'

# RSpec code changes based on this
require_relative 'fixes/rspec/support/ruby_features'
