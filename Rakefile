require 'bundler'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks

require 'opal/rspec/rake_task'
require_relative 'spec/rspec_provided/opal_spec_loader'

task :default => [:unit_specs, :verify_opal_specs, :integration_specs, :verify_other_specs]

desc 'Runs a set of specs in opal'
Opal::RSpec::RakeTask.new(:opal_specs) do |server, task|
  task.pattern = 'spec/opal/**/*_spec.{rb,opal}'
end

desc 'Generates an RSpec requires file free of dynamic requires'
task :generate_requires do
  # Do this free of any requires used to make this Rake task happen
  sh 'ruby -Irspec/lib -Irspec-core/lib/rspec -Irspec-support/lib/rspec util/create_requires.rb'
end

desc 'Runs a test to test browser based specs using Opal specs in spec/opal'
RSpec::Core::RakeTask.new :integration_specs do |t|
  t.pattern = 'spec/mri/integration/**/*_spec.rb'
end

desc 'Unit tests for MRI focused components of opal-rspec'
RSpec::Core::RakeTask.new :unit_specs do |t|
  t.pattern = 'spec/mri/unit/**/*_spec.rb'
end

desc 'A more limited spec suite to test pattern usage'
Opal::RSpec::RakeTask.new(:other_specs) do |server, task|
  task.pattern = 'spec/other/**/*_spec.rb'
end

desc "Run RSpec's specs (a work in progress)"
Opal::RSpec::RakeTask.new(:rspec_specs) do |server, task|
  Opal::RSpec::OpalSpecLoader.stub_requires
  files = Opal::RSpec::OpalSpecLoader.get_file_list
  with_sub = Opal::RSpec::OpalSpecLoader.sub_in_end_of_line files
  task.files = with_sub
  Opal::RSpec::OpalSpecLoader.append_additional_load_paths server
  server.debug = ENV['OPAL_DEBUG']
end

desc 'Verifies rspec_specs runs correctly'
task :verify_rspec_specs do
  EXPECTED_PENDING_COUNT = 1
  test_output = `rake rspec_specs`
  test_output.force_encoding 'UTF-8'
  count_match = /(\d+) examples, (\d+) failures, (\d+) pending/.match(test_output)
  raise 'Expected a finished count of test failures/success/etc. but did not see it' unless count_match
  total, failed, pending = count_match.captures
  actual_failures = []
  all_failed_examples = Regexp.new('Failed examples:\s(.*)', Regexp::MULTILINE).match(test_output).captures[0]
  all_failed_examples.scan /.*# (.*)/ do |match|
    actual_failures << match[0].strip
  end
  actual_failures.sort!
  expected_failures = Opal::RSpec::OpalSpecLoader.get_ignored_spec_failures
  remaining_failures = actual_failures.reject do |actual|
    expected_failures.any? do |expected|
      Regexp.new(expected[:exclusion]).match actual
    end
  end
  if remaining_failures.empty? and pending == EXPECTED_PENDING_COUNT.to_s
    puts 'Test successful!'
    puts "#{total} total specs, #{failed} expected failures, #{pending} expected pending"
  else
    puts "Raw output: #{test_output}" if ENV['RAW_OUTPUT']
    puts "Unexpected failures:\n\n#{remaining_failures.join("\n")}\n"
    puts '-----------Summary-----------'
    puts "Expected pending count #{EXPECTED_PENDING_COUNT}, actual pending count #{pending}"
    puts "Total 'failure' count: #{actual_failures.length}"
    puts "Unexpected failure count #{remaining_failures.length}"
    raise 'Test failed!'
  end
end

desc 'Verifies other_spec_dir task ran correctly'
task :verify_other_specs do
  test_output = `rake other_specs`
  unless /1 example, 0 failures/.match(test_output)
    raise "Expected 1 passing example, but got output '#{test_output}'"
  end
  puts 'Test successful'
end

desc 'Will run a spec suite (rake opal_specs) and check for expected combination of failures and successes'
task :verify_opal_specs do
  test_output = `rake opal_specs`
  raise "Expected test runner to fail due to failed tests, but got return code of #{$?.exitstatus}" if $?.success?
  count_match = /(\d+) examples, (\d+) failures, (\d+) pending/.match(test_output)
  raise 'Expected a finished count of test failures/success/etc. but did not see it' unless count_match
  total, failed, pending = count_match.captures

  actual_failures = []
  test_output.scan /\d+\) (.*)/ do |match|
    actual_failures << match[0].strip
  end
  actual_failures.sort!

  failure_messages = []

  bad_strings = [/.*is still running, after block problem.*/,
                 /.*should not have.*/,
                 /.*Expected \d+ after hits but got \d+.*/,
                 /.*Expected \d+ around hits but got \d+.*/]

  bad_strings.each do |regex|
    test_output.scan(regex) do |match|
      failure_messages << "Expected not to see #{regex} in output, but found match #{match}"
    end
  end

  expected_pending_count = 12
  expected_failures = File.read('spec/opal/expected_failures.txt').split("\n").compact.sort

  if actual_failures != expected_failures
    unexpected = actual_failures - expected_failures
    missing = expected_failures - actual_failures
    failure_messages << "Expected test failures do not match actual\n"
    failure_messages << "\nUnexpected fails:\n#{unexpected.join("\n")}\n\nMissing fails:\n#{missing.join("\n")}\n\n"
  end

  failure_messages << "Expected #{expected_pending_count} pending examples but actual was #{pending}" unless pending == expected_pending_count.to_s

  if failure_messages.empty?
    puts 'Test successful!'
    puts "#{total} total specs, #{failed} expected failures, #{pending} expected pending"
  else
    raise "Test failed, reasons:\n\n#{failure_messages.join("\n")}\n"
  end
end
