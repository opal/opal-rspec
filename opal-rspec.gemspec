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

  s.files          = `git ls-files`.split("\n")
  s.require_paths  = ['lib']

  s.add_dependency 'opal', '~> 0.4.4'
  s.add_dependency 'opal-sprockets', '~> 0.2.0'

  s.add_development_dependency 'rake'
end

