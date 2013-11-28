# -*- encoding: utf-8 -*-
require File.expand_path('../lib/opal/rspec/version', __FILE__)

Gem::Specification.new do |s|
  s.name         = 'opal-rspec'
  s.version      = Opal::RSpec::VERSION
  s.author       = 'Adam Beynon'
  s.email        = 'adam.beynon@gmail.com'
  s.homepage     = 'http://opalrb.org'
  s.summary      = 'RSpec for Opal'
  s.description  = 'Opal compatible rspec library'

  s.files = `git ls-files`.split("\n")
  s.files << 'opal/opal/rspec/rspec.js'

  s.require_paths  = ['lib']

  s.add_dependency 'opal', '~> 0.6.0'
  s.add_dependency 'opal-sprockets', '~> 0.4.0'

  s.add_dependency 'rspec',              '3.0.0.beta1'
  s.add_dependency 'rspec-support',      '3.0.0.beta1'
  s.add_dependency 'rspec-core',         '3.0.0.beta1'
  s.add_dependency 'rspec-mocks',        '3.0.0.beta1'
  s.add_dependency 'rspec-expectations', '3.0.0.beta1'

  s.add_development_dependency 'rake'
end

