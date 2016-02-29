# was fixed in https://github.com/rspec/rspec-support/commit/2dac0afd920e27ab557efc6bb51bebfd544256dc
# Remove once we get current with RSpec

# Need to ensure we're loaded before we patch
require 'rspec/support/spec/stderr_splitter'

class RSpec::Support::StdErrSplitter
  respond_to_name = (::RUBY_VERSION.to_f < 1.9) ? :respond_to? : :respond_to_missing?

  define_method respond_to_name do |*args|
    @orig_stderr.respond_to?(*args) || super(*args)
  end
end
