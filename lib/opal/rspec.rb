require 'opal'
require 'opal/rspec/version'

# Just register our opal code path with opal build tools
Opal.append_path File.expand_path('../../../opal', __FILE__)
Opal.append_path File.expand_path('../../../vendor_lib', __FILE__)

Opal::Processor.dynamic_require_severity = :warning

Opal::Processor.stub_file "rspec/matchers/built_in/have"
Opal::Processor.stub_file "diff/lcs"
Opal::Processor.stub_file "diff/lcs/hunk"
Opal::Processor.stub_file "fileutils"
Opal::Processor.stub_file "test/unit/assertions"
Opal::Processor.stub_file "coderay"
Opal::Processor.stub_file "optparse"
Opal::Processor.stub_file "shellwords"
Opal::Processor.stub_file "socket"
Opal::Processor.stub_file "uri"
Opal::Processor.stub_file "drb/drb"
