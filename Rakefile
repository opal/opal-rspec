require 'bundler'
Bundler.require

Bundler::GemHelper.install_tasks

require 'opal/rspec/rake_task'
Opal::RSpec::RakeTask.new(:default)

desc 'Generates an RSpec requires file free of dynamic requires'
task :generate_requires do
  # Do this free of any requires used to make this Rake task happen
  sh 'ruby -Irspec/lib -Irspec-core/lib/rspec -Irspec-support/lib/rspec util/create_requires.rb'
end

task :test do
  test_output = `rake default`
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

  expected_failures= ['promise should make example fail properly before async block reached',
                      'promise matcher fails properly',
                      'promise non-assertion failure in promise no args',
                      'promise non-assertion failure in promise string arg',
                      'promise non-assertion failure in promise exception arg',
                      'pending in example no promise would not fail otherwise, thus fails properly',
                      'async/sync mix fails properly if a sync test is among async tests',
                      'async/sync mix can finish running after a long delay and fail properly',
                      'be_truthy fails properly with truthy values',
                      'subject sync unnamed assertion fails properly should eq 43',
                      'subject sync unnamed fails properly during subject create',
                      'subject async assertion implicit fails properly should eq 43',
                      'subject async fails properly during creation explicit async',
                      'subject async fails properly during creation implicit usage',
                      'subject async assertion explicit async fails properly',
                      'hooks before async with async subject async match fails properly',
                      'hooks before async with async subject before :each fails properly should not reach the example',
                      'hooks before async with async subject before :each succeeds, assertion fails properly should not eq 42',
                      'hooks before async with async subject before :each succeeds, subject fails properly should not reach the example',
                      'hooks before async with async subject both subject and before(:each) fail properly should not reach the example',
                      'hooks before async with sync subject async match fails properly',
                      'hooks before async with sync subject before :each fails properly should not reach the example',
                      'hooks before async with sync subject match fails properly should not eq 42',
                      'hooks before sync with sync subject context fails properly should not reach the example',
                      'hooks before sync with sync subject before :each fails properly should not reach the example',
                      'hooks before sync with sync subject match fails properly should not eq 42',
                      'hooks before sync with sync subject first before :each in chain triggers failure inner context should not reach the example',
                      'hooks after sync after fails should eq 42',
                      'hooks after sync before fails should not reach the example',
                      'hooks after sync match fails async match',
                      'hooks after sync match fails sync match should eq 43',
                      'hooks after async after(:each) fails properly',
                      'hooks after async before(:each) fails properly',
                      'hooks after async match fails properly async match',
                      'hooks after async match fails properly sync match should eq 43',
                      'exception handling should fail properly if an exception is raised',
                      'exception handling should ignore an exception after a failed assertion'].sort
  if actual_failures != expected_failures
    unexpected = actual_failures - expected_failures
    missing = expected_failures - actual_failures
    failure_messages << "Expected test failures do not match actual\n"
    failure_messages << "\nUnexpected fails:\n#{unexpected.join("\n")}\n\nMissing fails:\n#{missing.join("\n")}\n\n"
  end

  failure_messages << "Expected #{expected_pending_count} pending examples but actual was #{pending}" unless pending == expected_pending_count.to_s

  if failure_messages.empty?
    puts 'Test successful!'
  else
    raise "Test failed, reasons:\n\n#{failure_messages.join("\n")}\n"
  end
end
