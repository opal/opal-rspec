require 'opal'
require 'opal-sprockets'
require 'opal/rspec/version'
require 'opal/rspec/sprockets_environment'
require 'opal/rspec/runner'

# Just register our opal code path with opal build tools
Opal.append_path File.expand_path('../../../lib-opal', __FILE__)
Opal.append_path File.expand_path('../../../stubs', __FILE__)

# Catch our git submodule included directories
%w{rspec rspec-core rspec-expectations rspec-mocks rspec-support}.each do |gem_name|
  Opal.append_path File.expand_path("../../../#{gem_name}/upstream/lib", __FILE__)
end

# Since we have better specs than before (and a script to deal with this), ignoring
Opal::Config.dynamic_require_severity = :ignore

module Opal
  module RSpec
    def self.spec_opts_code(spec_opts)
      code = []
      if spec_opts && !spec_opts.empty?
        code << 'RSpec.configure do |config|'

        if (match = /--(no-)?color\b/.match(spec_opts))
          color_value = !match.captures[0]
          # Have to use instance_variable_set because config.color= is designed to not allow overriding color once it's set, but
          # we do not yet have true SPEC_OPTS parsing via RSpec config to get it initially set
          code << "config.instance_variable_set(:@color, #{color_value})"
        end

        if (requires = spec_opts.scan(/(?:--require|-r) \S+/)).any?
          requires.map {|r| /--require (.*)/.match(r).captures[0]}.each do |req|
            code << %{require "#{req}"}
          end
        end

        if (match = /--format (\S+)/.match(spec_opts))
          formatter = match.captures[0]
          code << %{config.formatter = "#{formatter}"}
        end

        code << 'end'
      end
      code.join('; ')
    end
  end
end
