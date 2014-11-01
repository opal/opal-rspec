require 'bundler'
Bundler.require

Bundler::GemHelper.install_tasks

require 'opal/rspec/rake_task'
Opal::RSpec::RakeTask.new(:default)

desc "Build rspec.js"
task :build_rspec do
  gems = %w(rspec rspec-core rspec-expectations rspec-mocks rspec-support)

  File.open('opal/opal/rspec/rspec.js', 'w+') do |out|
    gems.each do |gem|
      spec = Gem::Specification.find_by_name gem
      lib  = File.join spec.gem_dir, 'lib'

      Dir["#{lib}/**/*.rb"].each do |file|
        asset = file.sub(/^#{lib}\//, '').sub(/\.rb$/, '')
        puts "#{file} => #{asset}"
        js = Opal.compile(File.read(file), requirable: true, file: asset,
                          dynamic_require_severity: :warning)

        out.puts js
      end
    end
  end
end
