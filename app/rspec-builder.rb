require 'rspec/core'
require 'rspec/mocks'
require 'rspec-expectations'

# we want access to BaseFormatter
require 'rspec/core/formatters/base_formatter'

# For now, we don't support mocking. This placeholder in rspec-core allows that.
require 'rspec/core/mocking/with_absolutely_nothing'
