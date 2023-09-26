require 'opal/rspec/util'

module Opal
  module RSpec
    VERSION = '1.1.0.alpha3'
  end
end

::Opal::RSpec.load_namespaced __dir__ + "/../../../rspec-core/upstream/lib/rspec/core/version.rb", ::Opal
::Opal::RSpec.load_namespaced __dir__ + "/../../../rspec-expectations/upstream/lib/rspec/expectations/version.rb", ::Opal
::Opal::RSpec.load_namespaced __dir__ + "/../../../rspec-mocks/upstream/lib/rspec/mocks/version.rb", ::Opal
::Opal::RSpec.load_namespaced __dir__ + "/../../../rspec-support/upstream/lib/rspec/support/version.rb", ::Opal
