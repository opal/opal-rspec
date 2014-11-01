require 'file'
require 'corelib/dir'
require 'thread'

require 'set'
require 'time'
require 'rbconfig'
require 'pathname'

def opal_require_rspec(path)
  `Opal.require(path)`
end

require 'opal/rspec/rspec'

# TODO: still needed? meh..
opal_require_rspec 'rspec/core/version'
opal_require_rspec 'rspec/core/flat_map'
opal_require_rspec 'rspec/core/filter_manager'
opal_require_rspec 'rspec/core/dsl'
opal_require_rspec 'rspec/core/reporter'
opal_require_rspec 'rspec/core/hooks'
opal_require_rspec 'rspec/core/memoized_helpers'
opal_require_rspec 'rspec/core/metadata'
opal_require_rspec 'rspec/core/pending'
opal_require_rspec 'rspec/core/formatters'
opal_require_rspec 'rspec/core/ordering'
opal_require_rspec 'rspec/core/world'
opal_require_rspec 'rspec/core/configuration'
opal_require_rspec 'rspec/core/option_parser'
opal_require_rspec 'rspec/core/configuration_options'
opal_require_rspec 'rspec/core/command_line'
opal_require_rspec 'rspec/core/runner'
opal_require_rspec 'rspec/core/example'
opal_require_rspec 'rspec/core/shared_example_group/collection'
opal_require_rspec 'rspec/core/shared_example_group'
opal_require_rspec 'rspec/core/example_group'

opal_require_rspec 'rspec/core/mocking/with_rspec'

opal_require_rspec 'rspec/support'
opal_require_rspec 'rspec/core'
opal_require_rspec 'rspec/expectations'
opal_require_rspec 'rspec/mocks'
opal_require_rspec 'rspec'

# FIXME: still needed?
opal_require_rspec 'rspec/core/formatters/base_text_formatter'
opal_require_rspec 'rspec/core/formatters/html_printer'
opal_require_rspec 'rspec/matchers/pretty'
opal_require_rspec 'rspec/matchers/built_in/base_matcher'
opal_require_rspec 'rspec/matchers/built_in/be'
