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

* **line 547**: opal cannot use mutable strings (see opal/rspec/fixes.rb)

* **line 564**: opal cannot use mutable strings (see opal/rspec/fixes.rb). Also, opal
does not support 2 regexp special characters yet (`\A` and `\z`).

### rspec/matchers/built_in/have.rb

* **line 1**: this is an error in rspec. This autoload does not exist so we must
stub the file.

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
