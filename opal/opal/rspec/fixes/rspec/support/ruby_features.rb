require 'rspec/support/ruby_features'

module ::RSpec::Support::RubyFeatures
  # Weird behavior when optional_and_splat_args_supported? is false (which is the case on Opal) and required_kw_args_supported? is true, so forcing this to false
  def required_kw_args_supported?
    false
  end
end
