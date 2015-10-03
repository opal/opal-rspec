# best guess for now, this is not defined by Opal, needed for instance_method_stasher.rb
RUBY_DESCRIPTION = RUBY_VERSION unless defined?(RUBY_DESCRIPTION)

class SecurityError < Exception; end unless defined?(SecurityError)

# This completely changes the struct class, so need it before RSpec runs
require_relative 'fixes/opal/compatibility'
require_relative 'fixes/opal/corelib/struct'
