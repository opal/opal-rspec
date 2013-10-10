require 'file'
require 'dir'
require 'thread'

require 'rspec/core'
require 'rspec/mocks'
require 'rspec-expectations'

# For now, we don't support mocking. This placeholder in rspec-core allows that.
# use any mocking. win.
require 'rspec/core/mocking/with_absolutely_nothing'

require 'opal-rspec/fixes'
require 'opal-rspec/text_formatter'
require 'opal-rspec/runner'
