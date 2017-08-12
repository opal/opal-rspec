class ::RSpec::Core::Configuration
  # This needs to be implemented if/when we allow the Opal side to decide what files to run
  def files_or_directories_to_run=(*files)
    @files_or_directories_to_run = []
    @files_to_run = nil
  end

  def requires=(paths)
    # can't change requires @ this stage, this method calls RubyProject which will crash on Opal
  end
end

class ::RSpec::Core::ConfigurationOptions
  def options_file_as_erb_string(path)
    # ERB.new(File.read(path), nil, '-').result(binding)
    # ERB.new(File.read(path), nil, '-')
    ''
  end
end

