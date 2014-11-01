require 'bundler'
Bundler.require

Bundler::GemHelper.install_tasks

require 'opal/rspec/rake_task'
Opal::RSpec::RakeTask.new(:default)


require 'fileutils'
desc "Copy RSpec sources"
task :copy_rspec do
  gems = %w(rspec rspec-core rspec-expectations rspec-mocks rspec-support)

  gems.each do |gem|
    spec = Gem::Specification.find_by_name gem
    lib  = File.join spec.gem_dir, 'lib'

    Dir["#{lib}/**/*.rb"].each do |file|
      out = file.sub(/^#{lib}\//, 'opal/')

      FileUtils.mkdir_p File.dirname(out)
      FileUtils.cp file, out
    end
  end
end
