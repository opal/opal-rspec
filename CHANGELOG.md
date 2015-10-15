## 0.5.0 (edge)

*   By default, any subject, it example block, before(:each), after(:each), and around that returns a promise will be executed asynchronously. Async is NOT yet supported for context level hooks. Async approach from < 0.4.3 will still work.

*   Update to RSpec 3.1 (core is 3.1.7, expectations/support 3.1.2, mocks 3.1.3)

*   Remove copy of source (and just rely on git submodule fetch)

*   Support passing a test pattern (include and exclude) and FileLists besides 'spec/**/*_spec.rb_ using the Rake task

*   Fixed issues with RSpec's BaseTextFormatter and made ProgressFormatter the default when run via the Rake task

*   Fixed issues with constants/example group naming

*   Basic nodejs runner support

*   Colors, formatter, and additional requires can be supplied from the command line via the SPEC_OPTS environment variable

*   Fix redundant messages with expectation fails

*   Browser formatter now works w/ progress bar

*   JSON formatter supported

*   More matchers enabled


## 0.4.3 (2015-06-14)

*   Allow the gem to be run under Opal 0.7 and 0.8
*   Fix some threading issues
*   Avoid some other calls to mutable-strings methods

## 0.4.2 (2015-03-28)

*   Avoid phantomjs warning messages

## 0.4.1 (2015-02-25)

*   Remove predicate matcher fixes as Opal supports $1..$9 special gvars.

*   Update Opal dependency for ~> 0.6.0.

*   Remove double-escaping in inline x-strings (from Opal bug fix).

*   Remove opal-sprockets dependency - build tools now part of opal.

*   Replaced browser formatter to use html printer from rspec

*   Add timeout support to asynchronous specs
