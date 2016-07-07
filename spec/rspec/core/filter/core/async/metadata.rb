rspec_filter 'metadata' do
  # Promise on the run, see opal alternates
  filter('RSpec::Core::Metadata backwards compatibility :example_group allows integration libraries like VCR to infer a fixture name from the example description by walking up nesting structure').unless { at_least_opal_0_11? }
end
