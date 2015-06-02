require 'bundler'
Bundler.require

Bundler::GemHelper.install_tasks

require 'opal/rspec/rake_task'
Opal::RSpec::RakeTask.new(:default)

desc 'Generates an RSpec requires file free of dynamic requires'
task :generate_requires do
  # Do this free of any requires used to make this Rake task happen
  sh 'ruby -Irspec/lib -Irspec-core/lib/rspec -Irspec-support/lib/rspec util/create_requires.rb'
  sh 'ruby util/normalize_requires.rb'
end

task :test do
  test_output = `rake default`
  raise "Expected test runner to fail due to failed tests, but got return code of #{$?.exitstatus}" if $?.success?
  total, failed, pending = /(\d+) examples, (\d+) failures, (\d+) pending/.match(test_output).captures
    
  actual_failures = []
  test_output.scan /\d+\) (.*)/ do |match|
    actual_failures << match[0]
  end
  actual_failures.sort!
  
  failure_messages = []
  
  expected_failures= ['Asynchronous helpers should make example fail properly before async block reached',
                      'Asynchronous helpers promise returned by example matcher fails properly',
                      'Asynchronous helpers promise returned by example promise fails properly no args',
                      'Asynchronous helpers promise returned by example promise fails properly string arg',
                      'Asynchronous helpers promise returned by example promise fails properly exception arg',
                      'Asynchronous helpers long delay fail properly',
                      'async/sync mix fails properly if a sync test is among async tests',
                      'async/sync mix can finish running after a long delay and fail properly',
                      'be_truthy fails properly with truthy values'].sort
  if actual_failures != expected_failures
    unexpected = actual_failures - expected_failures
    missing = expected_failures - actual_failures
    failure_messages << "Expected test failures do not match actual\n"
    failure_messages << "Expected:\n#{expected_failures.join("\n")}\n\nActual:\n#{actual_failures.join("\n")}"
    failure_messages << "\nUnexpected fails:\n#{unexpected.join("\n")}\n\nMissing fails:\n#{missing.join("\n")}\n\n"
  end
  
  failure_messages << "Expected 6 pending examples but actual was #{pending}" unless pending == '7'
  
  if failure_messages.empty?
    puts 'Test successful!'
  else
    raise "Test failed, reasons:\n\n#{failure_messages.join("\n")}\n"
  end
end
