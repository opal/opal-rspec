require 'bundler'
Bundler.require

require 'opal/rspec/rake_task'
Opal::RSpec::RakeTask.new(:default)

desc "Build opal/opal/rspec/rspec.js"
task :build do
  File.open('opal/opal/rspec/rspec.js', 'w+') do |out|
    out << build_rspec
  end
end

desc "Show dev/min sizes"
task :sizes do
  code = build_rspec
  min  = uglify code

  puts "\ndevelopment: #{code.size}, minified: #{min.size}"
end

def build_rspec
  Opal::Processor.dynamic_require_severity = :warning
  Opal.append_path 'app'

  Opal.use_gem 'rspec'
  Opal.use_gem 'rspec-expectations'

  %w[fileutils test/unit/assertions coderay optparse shellwords socket uri
     drb/drb diff/lcs diff/lcs/hunk].each do |asset|
    Opal::Processor.stub_file asset
  end

  # bug in rspec? this autoload doesnt exist so we must stub it
  Opal::Processor.stub_file 'rspec/matchers/built_in/have'

  Opal.process('rspec-builder')
end

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
