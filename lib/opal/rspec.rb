require 'opal'
require 'opal/rspec/version'

# Just register our opal code path with opal build tools
Opal.append_path File.expand_path('../../../opal', __FILE__)

# TODO: If this isn't performant, inline it
%w{rspec rspec-core rspec-expectations rspec-mocks rspec-support}.each do |gem|
  Opal.append_path File.expand_path("../../../#{gem}/lib", __FILE__)
end

Opal::Processor.dynamic_require_severity = :warning

%w{mutex_m prettyprint tempfile diff/lcs diff/lcs/block diff/lcs/callbacks diff/lcs/change diff/lcs/hunk diff/lcs/internals test/unit/assertions optparse shellwords socket uri drb/drb}.each do |mod|
  Opal::Processor.stub_file mod
end