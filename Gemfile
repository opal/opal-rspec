source 'https://rubygems.org'
gemspec

unless Dir['rspec{,-{core,expectations,mocks,support}}/upstream'].any?
  raise 'Run: "git submodule update --init" to get RSpec sources'
end

# These need to come from our local path in order for create_requires.rb to work properly
gem 'rspec',              path: 'rspec/upstream'
gem 'rspec-support',      path: 'rspec-support/upstream'
gem 'rspec-core',         path: 'rspec-core/upstream'
gem 'rspec-mocks',        path: 'rspec-mocks/upstream'
gem 'rspec-expectations', path: 'rspec-expectations/upstream'

gem 'pry'
