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

Then, to run your specs inside phantomjs (the default runner), just run the rake task:

```
bundle exec rake
```

Enable colors in the output

```
SPEC_OPTS="--color" bundle exec rake
```

Use a different formatter

```
SPEC_OPTS="--format json" bundle exec rake
```

The following formatters have been tested:
* Default (progress)
* Documentation
* JSON

If you need to specify additional requires for a custom formatter, you can do this:

```
SPEC_OPTS="--format SomeFormatter --require some_formatter" bundle exec rake
```

You can also customize the pattern of specs used similiar to how RSpec's rake task works:

```ruby
require 'opal/rspec/rake_task'
Opal::RSpec::RakeTask.new(:default) do |server, task|
	# server is an instance of Opal::Server in case you want to add to the load path, customize, etc.
	task.pattern = 'spec_alternate/**/*_spec.rb' # can also supply an array of patterns
end
```

Excluding patterns can be setup this way:
```ruby
require 'opal/rspec/rake_task'
Opal::RSpec::RakeTask.new(:default) do |server, task|
	task.exclude_pattern = 'spec_alternate/**/*_spec.rb' # can also supply an array of patterns
end
```

FileLists (as in Rake FileLists) can also be supplied:

```ruby
require 'opal/rspec/rake_task'
Opal::RSpec::RakeTask.new(:default) do |server, task|
	task.files = FileList['spec/**/something_spec.rb]
end
```

### Run specs in nodejs

Same options as above, you can use the RUNNER=node environment variable or use the Rake task like so:

```ruby
require 'opal/rspec/rake_task'
Opal::RSpec::RakeTask.new(:default) do |server, task|
  task.runner = :node
end
```

NOTE: nodejs runner does not yet work with source maps or debug mode

### Run specs in a browser

`opal-rspec` can use sprockets to build and serve specs over a simple rack
server. Add the following to a `config.ru` file (see config.ru in this GEM):

```ruby
require 'opal/rspec'
# or use Opal::RSpec::SprocketsEnvironment.new(spec_pattern='spec/opal/**/*_spec.{rb,opal}') to customize the pattern
sprockets_env = Opal::RSpec::SprocketsEnvironment.new
run Opal::Server.new(sprockets: sprockets_env) { |s|
  s.main = 'opal/rspec/sprockets_runner'
  sprockets_env.add_spec_paths_to_sprockets
  s.debug = false
}
```

Then run the rack server `bundle exec rackup` and visit `http://localhost:9292`
in any web browser.

## Async examples

`opal-rspec` adds support for async specs to rspec. These specs can be defined using 2 approaches:

1. Promises returned from subject or the `#it` block (preferred)
1. `#async` instead of `#it` (in use with opal-rspec <= 0.4.3)

### Promise approach

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
    # Argument is number of seconds, delay_with_promise is a convenience method that will
    # call setTimeout with the block and return a promise
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

  # async subject works too
  subject do
    delay_with_promise 0 do
      42
    end
  end

  it { is_expected.to eq 42 }

  # If you use an around block and have async specs, you must use this approach
  around do |example|
    puts 'do stuff before'
    example.run.then do
      puts 'do stuff after example'
    end
  end
end
```

Advantages:
* Assuming your subject under test (or matchers) return/use promises, the syntax is the same for sync or async specs

Limitations (apply to both async approaches):
* Right now, async `before(:context)` and `after(:context)` hooks cannot be async
* You cannot use an around hooks on any example where before(:each)/after(:each) hooks are async or with an async implicit subject
* `let` dependencies cannot be async, only subject
* Opal-rspec will not timeout while waiting for your async code to finish

### Async/it approach

This is the approach that was supported in opal-rspec <= 0.4.3 and it still works.

```ruby
describe MyClass2 do
	async 'HTTP requests should work' do
	  HTTP.get('/users/1.json') do |res|
	    async {
	      expect(res).to be_ok
	    }
	  end
	end
end
```

The block passed to the second `async` call informs the runner that this spec is finished
so it can move on. Any failures/expectations run inside this block will be run
in the context of the example.

Advantages:
* Hides promises from the specs

Disadvantages:
* Requires different syntax for async specs vs. sync specs

## Opal load path

NOTE: Only the deepest directory specified will be added to the Opal load path.

Example 1: For the example patterns above, only 'spec_alternate' will be added.

Example 2: Single base path

For a pattern of:
```ruby
'spec/other/**/*spec.rb'
```

'spec/other' will be added to the load path.

Example 3: Different base paths

Multiple patterns are specified that share the same parent:

For a pattern of:
```ruby
['spec/opal/**/*hooks_spec.rb', 'spec/other/**/*_spec.rb']
```

Only 'spec' will be added to the load path.

## Other Limitations/Known Issues

* Formatting
  * Backtrace info on specs is buggy ([no Kernel::caller method in Opal](https://github.com/opal/opal/issues/894)), in Firefox w/ the browser runner, no backtraces show up with failed specs
  * Diffs are not yet available when objects do not meet expectations (diff-lcs gem dependency has not been dealt with yet in Opal)
* Not all RSpec runner options are supported yet
* At some point, using node + Phantom's ability to read environment variables could be combined with a opal friendly optparse implementation to allow full options to be supplied/parsed
* Expect and should syntax are both enabled. They cannot be disabled due to bugs with the undef keyword in Opal
* Random order does not work yet due to lack of [srand/Random support](https://github.com/opal/opal/issues/639) and RSpec's bundled Random implementation (RSpec::Core::Backports::Random) locks the browser/Phantom. If you specify random order, it will be ignored.
* With Opal < 0.9, you can't access the example from named subject blocks (e.g. subject {|e| puts "example is #{e}" })
* nodejs runner
  * debug mode + source map support not there yet (see source map support - https://github.com/evanw/node-source-map-support)
  * currently running a lot slower than phantomjs, might need optimization
* Matchers
  * Predicate matchers (be_some_method_on_your_subject) do not currently work with delegate objects (Opal DelegateClass is incomplete)
  * Operator based comparison, except for ==, won't work on Opal 0.8 due to lack of method_missing support for operators. There is a PR to fix this in Opal 0.9: https://github.com/opal/opal/pull/1136
  * Descriptions on aliased/negated matchers won't be like normal RSpec due to several bugs: method owner not being correct (not fixed yet), blocks passed after arguments and hash (Opal 0.9 pull request open)
  * equal and eq matchers function largely the same right now since == and equal? in Opal are largely the same
  * Time based matching is not yet tested
  * Arity checking is not enabled by default in Opal but it can be. It's not currently enabled because it broke a lot of Opal specs. As a result, any matcher use (particularly respond_to) that depends on arity checking will not work
* Mocks
  * allow_any_instance/any_instance_of/any_instance will not work and may cause runner to crash due to issues with redefining the === operator, which breaks a case statement inside Hooks#find_hook
  * using expect/allow on String/Number (or any immutable bridged/native class) does not work
  * mocking class methods (including `::new`) is currently broken
  * class_double/class_spy are not supported (it depends on ClassVerifyingDouble inheriting from Module to support transferring nested constants, but that doesn't work on Opal)
  * object_spy is not supported (depends on proper initializer behavior in ObjectVerifyingDoubleMethods)
  * verifying partial doubles do not fully work yet
  * chaining and_return after do...end does not work
  * duck_type argument matching is still buggy
* Formatters must be supplied as full classes (otherwise Opal tries to load them from inside the Loader class)
* A lot of backports/monkey patches to Opal classes/methods are done to make this work on Opal 0.8. That means some things might work in your tests that do not work without opal-rspec. You can explore the opal/opal/rspec/fixes/opal directory to see what is being changed. All of the monkey patches check to see if the feature is "broken" before they apply themselves.

## Contributing

Install required gems at required versions:

    $ bundle install

opal-rspec uses a bundled copy of rspec to fix the areas where
opal cannot handle certain features of rspec. To build that file,
which is needed to run specs, use:

    $ git submodule update --init

When updating the RSpec versions, after updating the submodule revisions, you may need to use the generate_requires Rake task in order to pre-resolve RSpec's dynamic requires

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
