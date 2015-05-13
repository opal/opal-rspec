## 0.5.0beta1

*   Update to RSpec 3.1 (core is 3.1.7, expectations/support 3.1.2, mocks 3.1.3)

*   Remove copy of source (and just rely on git submodule fetch)

*   Remove predicate matcher fixes as Opal supports $1..$9 special gvars.

*   Update Opal dependency for ~> 0.6.0.

*   Remove double-escaping in inline x-strings (from Opal bug fix).

*   Remove opal-sprockets dependency - build tools now part of opal.

*   Replaced browser formatter to use html printer from rspec

*   Add timeout support to asynchronous specs

## 0.2.1  November 24, 2013
