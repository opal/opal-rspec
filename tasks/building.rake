Bundler::GemHelper.install_tasks

desc 'Generates an RSpec requires file free of dynamic requires'
task :generate_requires do
  # Do this free of any requires used to make this Rake task happen
  sh 'bin/generate_requires'
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
