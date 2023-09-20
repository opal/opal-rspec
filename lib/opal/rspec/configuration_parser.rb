require 'opal/rspec/util'
require 'optparse'

module Opal; module RSpec; module Core; end; end; end
# Load necessary files under Opal's namespace, so as not to conflict with RSpec if it's being loaded too.
# Later, we will monkey-patch those methods.
::Opal::RSpec.load_namespaced __dir__ + "/../../../rspec-core/upstream/lib/rspec/core/invocations.rb", ::Opal
::Opal::RSpec.load_namespaced __dir__ + "/../../../rspec-core/upstream/lib/rspec/core/option_parser.rb", ::Opal

class Opal::RSpec::Core::Parser
  alias parser_before_opal parser

  def parser(options)
    parser_before_opal(options).tap do |parser|
      parser.banner = "Usage: opal-rspec [options] [files or directories]\n\n"

      parser.separator ''
      parser.separator '  **** Opal specific options ****'
      parser.separator ''

      parser.on('-R', '--runner NAME', 'Use a different JS runner (default is nodejs)') do |name|
        options[:runner] = name
      end

      parser.separator ''
      parser.separator '  **** Help ****'
      parser.separator ''
    end
  end
end

class Opal::RSpec::Core::Invocations::PrintVersion
  alias call_before_opal call

  def call(options, err, out)
    exitcode = call_before_opal(options, err, out)
    out.puts "Opal #{Opal::VERSION}"
    out.puts "  - opal-rspec #{Opal::RSpec::VERSION}"
    exitcode
  end
end

module Opal::RSpec::Support
  def self.require_rspec_core(arg)
    require "opal/rspec/"+arg
  end
end
