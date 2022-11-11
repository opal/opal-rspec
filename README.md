# opal-rspec

[![Build Status](http://img.shields.io/travis/opal/opal-rspec/master.svg?style=flat)](http://travis-ci.org/opal/opal-rspec)
[![Quality](https://img.shields.io/codeclimate/maintainability-percentage/opal/opal-rspec.svg?style=flat)](https://codeclimate.com/github/opal/opal-rspec)
[![Version](http://img.shields.io/gem/v/opal-rspec.svg?style=flat)](https://rubygems.org/gems/opal-rspec)

An attempt at a compatibility layer of RSpec for Opal.

## Usage

Add `opal-rspec` to your Gemfile:

```ruby
gem 'opal-rspec'
```

*(since v0.7.1)*

Then type `opal-rspec --init`, this command will create a `spec-opal/` folder for you with a minimal `spec_helper.rb` file. At this point you can write your first opal-spec!

_spec-opal/simple_sum_spec.rb_

```rb
RSpec.describe 'a simple sum' do
  it 'equals two!' do
    expect(1 + 1).to eq(2)
  end
end
```

To run your specs, simply type:

```bash
bundle exec opal-rspec --color spec-opal/
```

## Requirements

Besides what's already reflected in the GEM dependencies:
* Browser if you want to run and debug tests that way

### Run specs in Headless Chromium

To run specs, a rake task can be added which will load all spec files from
`spec-opal/`:

```ruby
require 'opal/rspec/rake_task'
Opal::RSpec::RakeTask.new(:default) do |server, task|
  task.runner = :chrome
end
```

Then, to run your specs inside headless chrome (the default runner), just run the rake task:

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
  task.runner = :chrome
  # server is an instance of Opal::Server in case you want to add to the load path, customize, etc.
  task.pattern = 'spec_alternate/**/*_spec.rb' # can also supply an array of patterns
  # NOTE: opal-rspec, like rspec, only adds 'spec' to the Opal load path unless you set default_path
  task.default_path = 'spec_alternate'
end
```

Excluding patterns can be setup this way:

```ruby
Opal::RSpec::RakeTask.new(:default) do |server, task|
  task.runner = :chrome

  task.exclude_pattern = 'spec_alternate/**/*_spec.rb' # can also supply an array of patterns
end
```

FileLists (as in Rake FileLists) can also be supplied:

```ruby
Opal::RSpec::RakeTask.new(:default) do |server, task|
  task.runner = :chrome

  task.files = FileList['spec/**/something_spec.rb']
end
```

Headless Chromium will timeout by default after 60 seconds. If you need to lengthen the timeout value, set it like this:

```ruby
Opal::RSpec::RakeTask.new(:default) do |server, task|
  task.runner = :chrome

  task.files = FileList['spec/**/something_spec.rb']
  task.timeout = 80000 # 80 seconds, unit needs to be milliseconds
end
```

Arity checking is enabled by default. Opal allows you to disable arity checking (faster in production this way) but for unit testing, you probably want information on arity mismatch. If you wish to disable it, configure your Rake task like this:

```ruby
Opal::RSpec::RakeTask.new(:default) do |server, task|
  task.runner = :chrome

  task.arity_checking = :disabled
end
```

If you don't specify a runner using `task.runner`, a default one is Node. In this case you can also use `RUNNER=chrome` to run a particular test with Headless Chromium.

### Run specs in Node.js

Same options as above, you can use the `RUNNER=node` environment variable
(which is the default) or use the Rake task like so:

```ruby
Opal::RSpec::RakeTask.new(:default) do |server, task|
  task.runner = :node
end
```

### Run specs in a browser

Same options as above, you can use the `RUNNER=server` environment variable
(which is the default) or use the Rake task like so:

```ruby
Opal::RSpec::RakeTask.new(:default) do |server, task|
  task.runner = :server
end
```

### Run specs in a browser (Sprockets, deprecated)

`opal-rspec` can use sprockets to build and serve specs over a simple rack
server. Add the following to a `config.ru` file (see config.ru in this GEM):

```ruby
require 'opal/rspec/sprockets'
# or use Opal::RSpec::SprocketsEnvironment.new(spec_pattern='spec-opal/**/*_spec.{rb,opal}') to customize the pattern
sprockets_env = Opal::RSpec::SprocketsEnvironment.new
run Opal::Server.new(sprockets: sprockets_env) { |s|
  s.main = 'opal/rspec/sprockets_runner'
  sprockets_env.add_spec_paths_to_sprockets
  s.debug = true
}
```

Then run the rack server `bundle exec rackup` and visit `http://localhost:9292`
in any web browser.

A new feature as of opal-rspec 0.5 allows you to click a 'Console' button in the browser's test results and get a
clickable stack trace in the browser console. This should ease debugging with long, concatenated script files and trying
to navigate to where an exception occurred.

## Async examples

`opal-rspec` adds support for async specs to rspec.

```ruby
# await: *await*

require 'opal/rspec/async'

describe MyClass do
  # normal example
  it 'does something' do
    expect(:foo).to eq(:foo)
  end

  # async example
  it 'does something else, too' do
    promise = PromiseV2.new
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
      puts 'async before action'
    end
  end

  # async subject works too
  subject do
    delay_with_promise 0 do
      42
    end
  end

  it { expect(subject.await).to eq 42 }

  # If you use an around block and have async specs, you must use this approach
  around do |example|
    puts 'do stuff before'
    example.run_await.then do
      puts 'do stuff after example'
    end
  end
end
```

Advantages:

* Assuming your subject under test (or matchers) return/use promises, or uses `await` syntax, the syntax is the same for sync or async specs

Limitations:

* Opal-rspec will not timeout while waiting for your async code to finish

Changes since 1.0:

* If you use async features, it's crucial to use a `# await: *await*` magic comment (this will cause any call to a method containing an `await` word to be compiled with an `await` ES8 keyword)
* Both `let` and `subject` that return a promise (ie. are async; also if they) must be referenced with an `.await` method
* In `around` blocks, you must call `example.run_await` instead of just `example.run`
* Only `PromiseV2` is supported (`PromiseV1` may work, but you should migrate your application to use `PromiseV2` nevertheless, in Opal 2.0 it will become the default)

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

Since 0.8, the default spec location is `spec-opal` and the default source location is `lib-opal`. If your code aims to run the same specs and libraries for Ruby and Opal, you should use the following:

```ruby
Opal::RSpec::RakeTask.new do |server, task|
  server.append_path 'lib'
  task.default_path = 'spec'
  task.files = FileList['spec/**/*_spec.rb']
end
```

## Other Limitations/Known Issues

80%+ of the RSpec test suites pass so most items work but there are a few things that do not yet work. Do note that some of the items described here may actually work in the recent version.

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
* Configuration
  * Not all RSpec runner options are supported yet
  * At some point, using node + Phantom's ability to read environment variables could be combined with a opal friendly optparse implementation to allow full options to be supplied/parsed
  * Expect and should syntax are both enabled. They cannot be disabled due to past bugs with the `undef` keyword in Opal. Status of changing this via config has not been retested.
  * Random order does not work yet due to lack of [srand/Random support](https://github.com/opal/opal/issues/639) and RSpec's bundled Random implementation, `RSpec::Core::Backports::Random`, locks the browser/Phantom. If you specify random order, it will be ignored.
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

Copyright (C) 2022 by hmdne and the Opal contributors
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
