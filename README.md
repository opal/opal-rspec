# opal-rspec

[![Build Status](http://img.shields.io/travis/opal/opal-rspec/master.svg?style=flat)](http://travis-ci.org/opal/opal-rspec)

An attempt at a compatibility layer of rspec for opal.

[See the website for documentation](http://opalrb.org/docs/rspec/).

## Usage

Add `opal-rspec` to your Gemfile:

```ruby
gem 'opal-rspec'
```

### Run specs in phantomjs

To run specs, a rake task can be added which will load all spec files from
`spec/`:

```ruby
require 'opal/rspec/rake_task'
Opal::RSpec::RakeTask.new(:default)
```

Then, to run your specs inside phantomjs, just run the rake task:

```
bundle exec rake
```

### Run specs in a browser

`opal-rspec` can use sprockets to build and serve specs over a simple rack
server. Add the following to a `config.ru` file:

```ruby
require 'bundler'
Bundler.require

run Opal::Server.new { |s|
  s.main = 'opal/rspec/sprockets_runner'
  s.append_path 'spec'
  s.debug = false
}
```

Then run the rack server `bundle exec rackup` and visit `http://localhost:9292`
in any web browser.

## Async examples

`opal-rspec` adds support for async specs to rspec. These specs are defined using
`#async` instead of `#it`:

```ruby
describe MyClass do
  # normal example
  it 'does something' do
    expect(:foo).to eq(:foo)
  end

  # async example
  it 'does something else, too' do
    promise = Promise.new
		delay 1 do
			expect(:foo).to eq(:foo)
			promise.resolve
		end
		promise
  end
	
	it 'does another thing' do
		# Argument is number of seconds, delay_with_promise is a convenience method that will call setTimeout with the block and return a promise
		delay_with_promise 0 do
			expect(:foo).to eq(:foo)
		end
	end	
end

describe MyClass2 do
  # will wait for the before promise to complete before proceeding
	before do
		delay_with_promise 0 do
			puts 'async before 'action
		end
	end
	
	# If you use an around block and have async specs, you must use this approach
	around do |example|
		puts 'do stuff before'
		example.run.then do
			puts 'do stuff after example'
		end
	end
end
```
## Contributing

Install required gems at required versions:

    $ bundle install

opal-rspec uses a prebuilt version of rspec to fix the areas where
opal cannot handle certain features of rspec. To build that file,
which is needed to run specs, use:

    $ bundle exec rake build

This should build `opal/opal/rspec/rspec.js` ready to use.

### Run on command line

A simple rake task should run the example specs in `spec/`:

    $ bundle exec rake

### Run in the browser

Run attached rack app to handle building:

    $ bundle exec rackup

Visit the page in any browser and view the console:

    $ open http://localhost:9292

## Things to fix

`opal/opal-rspec/fixes.rb` contains a few bug fixes that need to be merged upstream
to opal itself. `app/rspec-builder.rb` is used to precompile rspec ready to be used
in `opal-rspec`. All requires from `core.rb` have been inlined as opal cannot require
dynamically at runtime.

## License

(The MIT License)

Copyright (C) 2013 by Adam Beynon

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
