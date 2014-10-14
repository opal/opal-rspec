require 'bundler'
Bundler.require


desc "Build opal/opal/rspec/rspec.js"
task :dist do
  File.open('opal/opal/rspec/rspec.js', 'w+') do |out|
    out << build_rspec
  end
end


Bundler::GemHelper.install_tasks
task :build => :dist


require 'opal/rspec/rake_task'
Opal::RSpec::RakeTask.new(:default)
task :default => :dist


desc "Show dev/min sizes"
task :sizes do
  code = build_rspec
  min  = uglify code

  puts "\ndevelopment: #{code.size}, minified: #{min.size}"
end




def build_rspec
  Opal::Processor.dynamic_require_severity = :warning

  code = []
  gems = %w(rspec rspec-core rspec-support rspec-expectations rspec-mocks)

  gems.each do |gem_name|
    spec = Gem::Specification.find_by_name gem_name
    gem_dir = File.join spec.gem_dir, 'lib'
    prefix = gem_dir + '/'

    Dir.glob(File.join(gem_dir, '**/*.rb')).each do |source|
      requirable = source.sub(prefix, '').sub(/\.rb$/, '')

      compiler = Opal::Compiler.new File.read(source),
        requirable: true, file: requirable, dynamic_require_severity: :warning

      code << compiler.compile
    end
  end

  stubs = %w(shellwords fileutils optparse)

  stubs.each do |stub|
    compiler = Opal::Compiler.new '', requirable: true, file: stub
    code << compiler.compile
  end

  code.join "\n"
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
