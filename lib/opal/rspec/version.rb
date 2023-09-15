module Opal
  module RSpec
    VERSION = '1.1.0.alpha1'
  end
end

load __dir__ + "/../../../rspec-core/upstream/lib/rspec/core/version.rb", ::Opal
load __dir__ + "/../../../rspec-expectations/upstream/lib/rspec/expectations/version.rb", ::Opal
load __dir__ + "/../../../rspec-mocks/upstream/lib/rspec/mocks/version.rb", ::Opal
load __dir__ + "/../../../rspec-support/upstream/lib/rspec/support/version.rb", ::Opal
