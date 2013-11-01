# opal-rspec

An attempt at a compatibility layer of rspec for opal.

## Usage

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
to opal itself. In app/rspec we have to stub various rspec files.

### rspec/core.rb

* **line 1**: `require_rspec` to fake require_relative doesnt work at runtime.
opal has to include all dependencies into build.

* **line 90**: heredoc fails to parse in opal as EOS is used within heredoc

* **line 171**: `&::Time.method(:now)` doesnt work so wrong method is set

### rspec/core/example_group.rb

* **line 434**: cannot parse heredoc as it uses EOS inline before string ends

* **line 547**: opal cannot use mutable strings (see opal/rspec/fixes.rb)

* **line 564**: opal cannot use mutable strings (see opal/rspec/fixes.rb). Also, opal
does not support 2 regexp special characters yet (`\A` and `\z`).

### rspec/core/project_initializer.rb

* **line 1**: opal cannot parse these heredocs (EOS used before last line of string)

### rspec/core/shared_example_group/collection.rb

* **line 17**: opal cannot parse command call inside aref

### rspec/matchers/built_in/have.rb

* **line 1**: this is an error in rspec. This autoload does not exist so we must
stub the file.
