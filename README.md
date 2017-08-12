# opal-rspec

[![Build Status](http://img.shields.io/travis/opal/opal-rspec/master.svg?style=flat)](http://travis-ci.org/opal/opal-rspec)
[![Quality](http://img.shields.io/codeclimate/github/opal/opal-rspec.svg?style=flat-square)](https://codeclimate.com/github/opal/opal-rspec)
[![Version](http://img.shields.io/gem/v/opal-rspec.svg?style=flat-square)](https://rubygems.org/gems/opal-rspec)

An attempt at a compatibility layer of RSpec for Opal.

#### For the README for the latest release, click [here](https://github.com/opal/opal-rspec/blob/releases/0-6-stable/README.md).

## Usage

Add `opal-rspec` to your Gemfile:

```ruby
gem 'opal-rspec'
```

## Requirements

Besides what's already reflected in the GEM dependencies:
* PhantomJS 2.0 or 2.1 for Rake task testing
* Browser if you want to run and debug tests that way

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
Opal::RSpec::RakeTask.new(:default) do |server, task|
  # server is an instance of Opal::Server in case you want to add to the load path, customize, etc.
  task.pattern = 'spec_alternate/**/*_spec.rb' # can also supply an array of patterns
  # NOTE: opal-rspec, like rspec, only adds 'spec' to the Opal load path unless you set default_path
  task.default_path = 'spec_alternate'
end
```

Excluding patterns can be setup this way:

```ruby
Opal::RSpec::RakeTask.new(:default) do |server, task|
  task.exclude_pattern = 'spec_alternate/**/*_spec.rb' # can also supply an array of patterns
end
```

FileLists (as in Rake FileLists) can also be supplied:

```ruby
Opal::RSpec::RakeTask.new(:default) do |server, task|
  task.files = FileList['spec/**/something_spec.rb']
end
```

PhantomJS will timeout by default after 60 seconds. If you need to lengthen the timeout value, set it like this:

```ruby
Opal::RSpec::RakeTask.new(:default) do |server, task|
  task.files = FileList['spec/**/something_spec.rb']
  task.timeout = 80000 # 80 seconds, unit needs to be milliseconds
end
```

Arity checking is enabled by default. Opal allows you to disable arity checking (faster in production this way) but for unit testing, you probably want information on arity mismatch. If you wish to disable it, configure your Rake task like this:

```ruby
Opal::RSpec::RakeTask.new(:default) do |server, task|
  task.arity_checking = :disabled
end
```

### Run specs in nodejs

Same options as above, you can use the `RUNNER=node` environment variable or use the Rake task like so:

```ruby
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
# or use Opal::RSpec::SprocketsEnvironment.new(spec_pattern='spec-opal/**/*_spec.{rb,opal}') to customize the pattern
sprockets_env = Opal::RSpec::SprocketsEnvironment.new
run Opal::Server.new(sprockets: sprockets_env) { |s|
  s.main = 'opal/rspec/sprockets_runner'
  sprockets_env.add_spec_paths_to_sprockets
  s.debug = false
}
```

Then run the rack server `bundle exec rackup` and visit `http://localhost:9292`
in any web browser.

A new feature as of opal-rspec 0.5 allows you to click a 'Console' button in the browser's test results and get a
clickable stack trace in the browser console. This should ease debugging with long, concatenated script files and trying
to navigate to where an exception occurred.

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

NOTE: Only the 'spec' directory will be added to the Opal load path by default. Use the Rake task's `default_path` setting to change that. Here's an example of that.

```ruby
Opal::RSpec::RakeTask.new do |server, task|
  task.default_path = 'spec/javascripts'
end
```

If you need to add additional load paths to run your specs, then use the `append_path` method like this:

```ruby
Opal::RSpec::RakeTask.new do |server, task|
  server.append_path 'some_path'
end
```

## Other Limitations/Known Issues

80%+ of the RSpec test suites pass so most items work but there are a few things that do not yet work.

* Core Examples
  * Example groups included like this are currently not working:
```ruby
module TestMod
  def self.included(base)
    base.class_eval do
      describe 'foo' do
      ...
      end
    end
  end
end

RSpec.configure do |c|
  c.include TestMod
end
```
* Formatting/Reporting
  * Specs will not have file path/line number information on them unless they are supplied from user metadata or they fail, see [this issue](https://github.com/opal/opal-rspec/issues/36)
  * In Firefox w/ the browser runner, no backtraces show up with failed specs
  * Diffs are not yet available when objects do not meet expectations (diff-lcs gem dependency has not been dealt with yet in Opal)
* Configuration
  * Not all RSpec runner options are supported yet
  * At some point, using node + Phantom's ability to read environment variables could be combined with a opal friendly optparse implementation to allow full options to be supplied/parsed
  * Expect and should syntax are both enabled. They cannot be disabled due to past bugs with the `undef` keyword in Opal. Status of changing this via config has not been retested.
  * Random order does not work yet due to lack of [srand/Random support](https://github.com/opal/opal/issues/639) and RSpec's bundled Random implementation, `RSpec::Core::Backports::Random`, locks the browser/Phantom. If you specify random order, it will be ignored.
* Nodejs runner
  * debug mode + source map support not there yet (see source map support - https://github.com/evanw/node-source-map-support)
  * currently running a lot slower than phantomjs, might need optimization
* Matchers
  * predicate matchers (be_some_method_on_your_subject) do not currently work with delegate objects (Opal `DelegateClass` is incomplete)
  * equal and eq matchers function largely the same right now since `==` and `equal?` in Opal are largely the same
  * time based matching is not yet tested
  * Due to some issues with splats and arity in Opal, respond_to matchers may not work properly on methods with splats
* Mocks
  * `allow_any_instance/any_instance_of/any_instance` are unstable and may cause runner to crash due to issues with redefining the `===` operator, which breaks a case statement inside `Hooks#find_hook`
  * using expect/allow on `String`, `Number`, or any immutable bridged/native class, does not work since rspec-mocks uses singleton classes and those cannot be defined on immutable objects
  * mocking class methods (including `::new`) is currently broken
  * `class_double/class_spy` are not supported (it depends on `ClassVerifyingDouble` inheriting from `Module` to support transferring nested constants, but that doesn't work on Opal)
  * `object_spy` is not supported (depends on proper initializer behavior in `ObjectVerifyingDoubleMethods`)
  * verifying partial doubles do not fully work yet (arity issues with Opal)
  * chaining and_return after do...end does not work
  * duck_type argument matching is still buggy
  * RSpec's marshal support does not yet work with Opal's marshaller (so patch_marshal_to_support_partial_doubles config setting is not supported)

## Contributing

Install required gems at required versions:

    $ bundle install

opal-rspec uses a bundled copy of rspec to fix the areas where
opal cannot handle certain features of rspec. To build that file,
which is needed to run specs, use:

    $ git submodule update --init

When updating the RSpec versions, after updating the submodule revisions, you may need to use the generate_requires Rake task in order to pre-resolve RSpec's dynamic requires

## License

(The MIT License)

Copyright (C) 2015 by Brady Wied
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
