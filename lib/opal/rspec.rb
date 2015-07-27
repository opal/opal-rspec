require 'opal'
require 'opal/rspec/version'
require 'opal/minitest'

# Just register our opal code path with opal build tools
Opal.append_path File.expand_path('../../../opal', __FILE__)

# Catch our git submodule included directories
%w{rspec rspec-core rspec-expectations rspec-mocks rspec-support}.each do |gem|
  Opal.append_path File.expand_path("../../../#{gem}/lib", __FILE__)
end

Opal::Processor.dynamic_require_severity = :warning

stubs = [
  'mutex_m', # Used with some threading operations but seems to run OK without this
  'prettyprint',
  'tempfile', # Doesn't exist in Opal
  'diff/lcs',
  'diff/lcs/block',
  'diff/lcs/callbacks',
  'diff/lcs/change',
  'diff/lcs/hunk',
  'diff/lcs/internals',
  'test/unit/assertions',

  # Opal doesn't have optparse, yet
  'optparse',

  'shellwords',
  'socket',
  'uri',
  'drb/drb',

  # Minitest used to be in stdlib, now is in opal-minitest GEM,
  # but this file does not exist
  # (referenced from minitest_assertions_adapter.rb in RSpec)
  'minitest/unit',

  'cgi/util',
]

stubs.each {|mod| Opal::Processor.stub_file mod }
