# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "opal/rspec/version"

Gem::Specification.new do |spec|
  spec.name          = "opal-rspec"
  spec.version       = Opal::RSpec::VERSION
  spec.authors       = ['Adam Beynon', 'Brady Wied', 'Elia Schito']
  spec.email         = ['elia@schito.me']

  spec.summary       = %q{RSpec for Opal}
  spec.description   = %q{Opal compatible RSpec library}
  spec.homepage      = 'https://github.com/opal/opal-rspec'
  spec.license       = "MIT"

  spec.files         = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'opal', ['>= 0.10.0', '< 0.12']
  spec.add_dependency 'opal-sprockets'

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'chromedriver-helper'
  spec.add_development_dependency 'selenium-webdriver'
  spec.add_development_dependency 'capybara'
  spec.add_development_dependency 'launchy'
  spec.add_development_dependency 'appraisal'
end

