require 'bundler'
Bundler.require

require 'opal/rspec/rake_task'
Opal::RSpec::RakeTask.new(:default)

desc "Build opal-rspec/rspec.js"
task :build do
  Opal::Processor.dynamic_require_severity = :warning
  Opal.append_path 'app'

  Opal.use_gem 'rspec'
  Opal.use_gem 'rspec-expectations'

  code = Opal.process('rspec-builder')
  min  = uglify code

  puts "\nDev: #{code.size}, min: #{min.size}"

  File.open('opal/opal/rspec/rspec.js', 'w+') do |out|
    out << code
  end
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

