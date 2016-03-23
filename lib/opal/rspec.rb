require 'opal'
require 'opal/rspec/version'
require 'opal/rspec/sprockets_environment'

# Just register our opal code path with opal build tools
Opal.append_path File.expand_path('../../../opal', __FILE__)

# Catch our git submodule included directories
%w{rspec rspec-core rspec-expectations rspec-mocks rspec-support}.each do |gem|
  Opal.append_path File.expand_path("../../../#{gem}/lib", __FILE__)
end

# Since we have better specs than before (and a script to deal with this), ignoring
Opal::Config.dynamic_require_severity = :ignore

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
  'cgi/util',
  'minitest', # RSpec uses require to see if minitest is there, opal/sprockets won't like that, so stub it
  'minitest/unit',
  'minitest/assertions'
]

::Opal::Config.stubbed_files.merge(stubs)
