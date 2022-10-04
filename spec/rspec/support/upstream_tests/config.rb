class Opal::RSpec::UpstreamTests::Config
  def initialize(gem_name = ::RSpec.current_example.metadata[:gem_name])
    @gem_name = gem_name
  end

  def stubs
    [
      'rubygems',
      'aruba/api', # Cucumber lib that supports file creation during testing, N/A for us
      'simplecov', # hooks aren't available on Opal
      'tmpdir',
      'rspec/support/spec/shell_out', # only does stuff Opal can't support anyways
      'rspec/support/spec/library_wide_checks', # `git ls-files -z`
      'timeout',
      'yaml',
      'support/capybara',
    ]
  end

  def files_to_run
    Opal::RSpec::UpstreamTests::FilesToRun.new(@gem_name).to_a
  end

  def load_paths
    [
      File.join(submodule_root, 'spec'),
      'spec/rspec/shared'
    ]
  end

  def submodule_root
    File.expand_path("../../../../../#{@gem_name}", __FILE__)
  end
end
