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
    
  failures = []
  test_output.scan /\d+\) (.*)/ do |match|
    failures << match[0]
  end
  
  unexpected_failures = failures.reject {|f| /fails? properly/.match f}
  raise "Expected only fail properly tests, but failures included: #{unexpected_failures}" unless unexpected_failures.empty?
  
  raise "Expected 10 examples to fail but actual was #{failed}" unless failed == '9'
  raise "Expected 6 pending examples but actual was #{pending}" unless pending == '7'
  
  puts 'Test successful!'
end
