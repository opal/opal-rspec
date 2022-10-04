require 'rspec/core/rake_task'

# Rake.application.last_comment was removed in Rake v12.0
# https://github.com/ruby/rake/commit/e76242ce7ef94568399a50b69bda4b723dab7c75
def (Rake.application).last_comment; last_description; end unless Rake.application.respond_to? :last_comment

desc 'Runs all RSpec specs'
task :rspec do
  sh 'bundle exec rspec'
end

require 'opal/rspec/rake_task'

desc 'Runs a set of specs in opal'
Opal::RSpec::RakeTask.new do |_, task|
  task.pattern = ENV['PATTERN'] || 'spec-opal/**/*_spec.{rb,opal}'
end

#
# desc 'Run the full suite, this can time out on Travis'
# task :default => [
#   :unit_specs,
#   :verify_opal_specs,
#   :integration_specs,
#   :verify_rspec_specs,
# ]
#
# desc 'Run only tests that use the opal-rspec Rake task'
# task :rake_only => [
#   :verify_rspec_specs,
#   :verify_opal_specs,
# ]
#
# desc 'Sanity checks a given version of MRI and run a basic check'
# task :mri_sanity_check => [
#   :unit_specs,
#   :integration_specs,
# ]
#
#
# desc 'Runs a test to test browser based specs using Opal specs in spec-opal'
# RSpec::Core::RakeTask.new :integration_specs do |t|
#   t.pattern = 'spec/integration/**/*_spec.rb'
# end
#
# desc 'Unit tests for MRI focused components of opal-rspec'
# RSpec::Core::RakeTask.new :unit_specs do |t|
#   t.pattern = 'spec/opal/rspec/**/*_spec.rb'
# end
#
Opal::RSpec::RakeTask.new(:other_specs) do |_, task|
  task.pattern = 'spec-opal/other/dummy_spec.rb'
end

Opal::RSpec::RakeTask.new(:color_on_by_default) do |_, task|
  task.pattern = 'spec-opal/other/color_on_by_default_spec.rb'
end
#
# # Opal::RSpec::CoreSpecLoader.rake_tasks_for(:rspec_core_specs)
# # Opal::RSpec::ExpectationSpecLoader.rake_tasks_for(:rspec_expectation_specs)
# # Opal::RSpec::SupportSpecLoader.rake_tasks_for(:rspec_support_specs)
# # Opal::RSpec::MocksSpecLoader.rake_tasks_for(:rspec_mocks_specs)
#
# # These are done
# desc 'Verifies all RSpec specs'
# task :verify_rspec_specs => [
#   :verify_rspec_support_specs,
#   :verify_rspec_core_specs,
#   :verify_rspec_expectation_specs,
#   :verify_rspec_mocks_specs,
# ]
#
# desc 'Will run a spec suite (rake spec:opal) and check for expected combination of failures and successes'
# task :verify_opal_specs do
#   sh 'rspec spec/integration/verify_opal_specs_spec.rb'
# end
#
