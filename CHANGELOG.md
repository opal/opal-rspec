# Opal-RSpec Changelog

## 0.7.1 - unreleased

- add a project initializer: `opal-rspec --init`


## 0.7.0 - 2019-02-03

- Drop support for the legacy async syntax

- Complete internal overhaul

- Support for Opal v0.11


## 0.6.1 - 2017-05-25

- Fixed compatibility with Rake 12

- Open up to opal 0.11 (not officially supported yet)


## 0.6.0 - 2016-08-29

- Support for Opal 0.8/0.9 removed

- Opal 0.10 support

- Arity checking enabled by default

- Dropped support for PhantomJS < 2.0

- Removed `Kernel#caller` monkey patch so test file/line metadata is only available if supplied via test metadata or for failures. Should improve performance since an exception isn't thrown for every test to gather the data


## 0.5.0 - 2015-12-08

- By default, any subject, it example block, before(:each), after(:each), and around that returns a promise will be executed asynchronously. Async is NOT yet supported for context level hooks. Async approach from < 0.4.3 will still work.

- Update to RSpec 3.1 (core is 3.1.7, expectations/support 3.1.2, mocks 3.1.3)

- Opal 0.9 compatibility

- A lot more aspects of RSpec should work now as 20+ Opal pull requests were completed from opal-rspec work

- Remove copy of source from opal-rspec git repo (and just rely on git submodule fetch)

- Rake task improvements:
  - supports passing a test pattern (include and exclude) and FileLists besides 'spec/**/*_spec.rb
  - colors, formatter, and additional requires can be supplied from the command line via the SPEC_OPTS environment variable

- Formatters:
  - Fixed issues with RSpec's BaseTextFormatter and made ProgressFormatter the default when run via the Rake task
  - Fix redundant messages with expectation fails
  - Browser formatter now works w/ progress bar and has a 'Dump to console' link that will put a clickable stack trace for a failed example in the browser console
  - JSON formatter supported

- Fixed issues with constants/example group naming

- Basic nodejs runner support

- A lot more matchers enabled

*  PhantomJS 2.0 compatibility (also still compatible with 1.9.8). Thanks to @aost. Closes out https://github.com/opal/opal-rspec/issues/42


## 0.4.3 - 2015-06-14

- Allow the gem to be run under Opal 0.7 and 0.8
- Fix some threading issues
- Avoid some other calls to mutable-strings methods


## 0.4.2 - 2015-03-28

- Avoid phantomjs warning messages


## 0.4.1 - 2015-02-25

- Remove predicate matcher fixes as Opal supports $1..$9 special gvars.

- Update Opal dependency for ~> 0.6.0.

- Remove double-escaping in inline x-strings (from Opal bug fix).

- Remove opal-sprockets dependency - build tools now part of opal.

- Replaced browser formatter to use html printer from rspec

- Add timeout support to asynchronous specs
