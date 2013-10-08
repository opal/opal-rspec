require 'opal'
require 'opal-rspec'

# make sure should and expect syntax are both loaded
RSpec::Expectations::Syntax.enable_should
RSpec::Expectations::Syntax.enable_expect

# opal doesnt yet support module_exec for defining methods in modules properly
module RSpec::Matchers
  alias_method :expect, :expect
end

rspec_config = RSpec.configuration

# mock frameworks currently broken, so skip for now
# UPDATE: is this fixed by module.new fix?
def rspec_config.configure_mock_framework
  nil
end

describe "Adam" do
  it "should eat" do

  end
end

describe "Benjamin" do
  it "likes cream in his tea" do

  end
end
