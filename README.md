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

### Immutable strings

`opal/opal/rspec/fixes.rb` contains two stub methods as those core rspec methods
try to use mutable strings, which are not supported in opal.

### HEREDOCS

Parsing heredocs causes problems

* rspec/core/shared_example_group/collection.rb
* rspec/core/example_group.rb
* rspec/core/project_initializer.rb
* rspec/core/shared_example_group.rb
* rspec/matchers/built_in/change.rb

### require

When used as expression generating empty code (syntax error)

* rspec/core/configuration.rb

### Bad autoload/missing file

An autoload exists, but the file referenced doesnt actually exist, so we
have to stub it

* rspec/matchers/built_in/have.rb
