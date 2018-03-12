require 'bundler'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks

require 'opal/rspec/rake_task'
# require_relative 'spec/rspec/core/core_spec_loader'
require_relative 'spec/rspec/expectations/expectation_spec_loader'
require_relative 'spec/rspec/support/support_spec_loader'
require_relative 'spec/rspec/mocks/mocks_spec_loader'

desc 'Run the full suite, this can time out on Travis'
task :default => [
  :unit_specs,
  :verify_opal_specs,
  :integration_specs,
  :verify_rspec_specs,
]

desc 'Run only tests that use the opal-rspec Rake task'
task :rake_only => [
  :verify_rspec_specs,
  :verify_opal_specs,
]

desc 'Sanity checks a given version of MRI and run a basic check'
task :mri_sanity_check => [
  :unit_specs,
  :integration_specs,
]

desc 'Runs a set of specs in opal'
Opal::RSpec::RakeTask.new do |_, task|
  task.pattern = ENV['PATTERN'] || 'spec-opal/**/*_spec.{rb,opal}'
end

desc 'Generates an RSpec requires file free of dynamic requires'
task :generate_requires do
  # Do this free of any requires used to make this Rake task happen
  sh 'ruby -Irspec/lib -Irspec-core/lib/rspec -Irspec-support/lib/rspec util/create_requires.rb'
end

# Rake.application.last_comment was removed in Rake v12.0
# https://github.com/ruby/rake/commit/e76242ce7ef94568399a50b69bda4b723dab7c75
def (Rake.application).last_comment; last_description; end unless Rake.application.respond_to? :last_comment

desc 'Runs a test to test browser based specs using Opal specs in spec-opal'
RSpec::Core::RakeTask.new :integration_specs do |t|
  t.pattern = 'spec/integration/**/*_spec.rb'
end

desc 'Unit tests for MRI focused components of opal-rspec'
RSpec::Core::RakeTask.new :unit_specs do |t|
  t.pattern = 'spec/opal/rspec/**/*_spec.rb'
end

Opal::RSpec::RakeTask.new(:color_on_by_default) do |_, task|
  task.pattern = 'spec-opal/other/color_on_by_default_spec.rb'
end

# Opal::RSpec::CoreSpecLoader.rake_tasks_for(:rspec_core_specs)
# Opal::RSpec::ExpectationSpecLoader.rake_tasks_for(:rspec_expectation_specs)
# Opal::RSpec::SupportSpecLoader.rake_tasks_for(:rspec_support_specs)
# Opal::RSpec::MocksSpecLoader.rake_tasks_for(:rspec_mocks_specs)

# These are done
desc 'Verifies all RSpec specs'
task :verify_rspec_specs => [
  :verify_rspec_support_specs,
  :verify_rspec_core_specs,
  :verify_rspec_expectation_specs,
  :verify_rspec_mocks_specs,
]

desc 'Will run a spec suite (rake spec:opal) and check for expected combination of failures and successes'
task :verify_opal_specs do
  sh 'rspec spec/integration/verify_opal_specs_spec.rb'
end

desc "Build build/opal-rspec.js"
task :dist do
  require 'fileutils'
  FileUtils.mkdir_p 'build'

  builder = Opal::Builder.new(stubs: Opal::Config.stubbed_files, # stubs already specified in lib/opal/rspec.rb
                              compiler_options: { dynamic_require_severity: :ignore }) # RSpec is full of dynamic requires
  src = builder.build('opal-rspec')

  min = uglify src
  gzp = gzip min

  File.open('build/opal-rspec.js', 'w+') do |out|
    out << src
  end

  puts "development: #{src.size}, minified: #{min.size}, gzipped: #{gzp.size}"
end

# Used for uglifying source to minify
def uglify(str)
  IO.popen('uglifyjs', 'r+') do |i|
    i.puts str
    i.close_write
    return i.read
  end
rescue Errno::ENOENT
  $stderr.puts '"uglifyjs" command not found (install with: "npm install -g uglify-js")'
  nil
end

# Gzip code to check file size
def gzip(str)
  IO.popen('gzip -f', 'r+') do |i|
    i.puts str
    i.close_write
    return i.read
  end
rescue Errno::ENOENT
  $stderr.puts '"gzip" command not found, it is required to produce the .gz version'
  nil
end
