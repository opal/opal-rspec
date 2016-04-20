rspec_filter 'ruby_features' do
  # platform will not match up for obvious reasons
  filter /RSpec::Support::Ruby jruby.*/
  filter /RSpec::Support::Ruby rbx.*/
  filter /RSpec::Support::Ruby mri.*/
end
