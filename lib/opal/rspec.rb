require 'opal'
require 'opal-sprockets'
require 'opal/rspec/version'
require 'opal/rspec/runner'
require 'opal/rspec/configuration_parser'

# Just register our opal code path with opal build tools
Opal.append_path File.expand_path('../../../lib-opal', __FILE__)
Opal.append_path File.expand_path('../../../stubs', __FILE__)

# Catch our git submodule included directories
%w{rspec rspec-core rspec-expectations rspec-mocks rspec-support diff-lcs}.each do |gem_name|
  Opal.append_path File.expand_path("../../../#{gem_name}/upstream/lib", __FILE__)
end

# Since we have better specs than before (and a script to deal with this), ignoring
Opal::Config.dynamic_require_severity = :ignore

module Opal
  module RSpec
    autoload :ProjectInitializer, 'opal/rspec/project_initializer'

    def self.convert_spec_opts(opts)
      opts ||= ENV['SPEC_OPTS'] || {}

      unless opts.is_a? Hash
        opts = Shellwords.split(opts) if opts.is_a? String
        opts = Opal::RSpec::Core::Parser.parse(opts || [])
      end

      opts
    end

    def self.spec_opts_code(spec_opts)
      spec_opts = convert_spec_opts(spec_opts)

      code = []
      code << '# await: true'

      # New API - passthru options
      spec_opts[:files_or_directories_to_run] ||= []

      code << "$rspec_opts = #{spec_opts.inspect}"
      code << "$0 = 'opal-rspec'"

      code << '::RSpec::Core::Runner.invoke.__await__'
      code.join("\n")
    end
  end
end
