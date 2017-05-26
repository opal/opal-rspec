source 'https://rubygems.org'
gemspec

unless Dir['rspec{,-{core,expectations,mocks,support}}'].any?
  warn 'Run: "git submodule update --init" to get RSpec sources'
end

case (opal_version = ENV['OPAL_VERSION'])
when 'master'
  gem 'opal', github: 'opal/opal', branch: 'master'
  gem 'opal-sprockets', github: 'opal/opal-sprockets'
when nil
  gem 'opal' # let bundler pick a version
else
  gem 'opal', opal_version
end

# These need to come from our local path in order for create_requires.rb to work properly
gem 'rspec',              path: 'rspec'
gem 'rspec-support',      path: 'rspec-support'
gem 'rspec-core',         path: 'rspec-core'
gem 'rspec-mocks',        path: 'rspec-mocks'
gem 'rspec-expectations', path: 'rspec-expectations'
