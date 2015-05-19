source 'https://rubygems.org'
gemspec

# Only run this if we don't have them
system 'git submodule update --init' unless Dir.glob('rspec-core/**').any?

gem 'rspec',              path: 'rspec'
gem 'rspec-support',      path: 'rspec-support'
gem 'rspec-core',         path: 'rspec-core'
gem 'rspec-mocks',        path: 'rspec-mocks'
gem 'rspec-expectations', path: 'rspec-expectations'

# Opal 0.8 still in development
gem 'opal', git: 'https://github.com/opal/opal.git'
