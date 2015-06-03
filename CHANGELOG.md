## 0.5.0 (edge)

*   By default, any subject, it example block, before(:each), after(:each), and around that returns a promise will be executed asynchronously. Async is NOT yet supported for context level hooks.

*   Update to RSpec 3.1 (core is 3.1.7, expectations/support 3.1.2, mocks 3.1.3)

*   Remove copy of source (and just rely on git submodule fetch)

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
