class Opal::RSpec::UpstreamTests::FilesToRun
  def initialize(gem_name = ::RSpec.current_example.metadata[:gem_name])
    @gem_name = gem_name
  end

  def to_a
    FileList[include_pattern].exclude(exclude_pattern)
  end

  private

  def submodule_root
    File.expand_path("../../../../../#{@gem_name}", __FILE__)
  end

  def gem_root
    File.join(submodule_root, 'upstream')
  end

  def include_pattern
    File.join(gem_root, 'spec/**/*_spec.rb')
  end

  def exclude_pattern
    filepath = File.join(submodule_root, 'spec/files_to_exclude.txt')
    content = File.read(filepath)
    patterns = content.split("\n").reject { |line| line.empty? || line.start_with?('#') }

    missing_exclusions = patterns.select do |pattern|
      FileList[pattern].empty?
    end
    if missing_exclusions.any?
      raise "Expected to exclude #{missing_exclusions} as noted in spec_files_exclude.txt but we didn't find these files. Has RSpec been upgraded?"
    end

    patterns
  end
end
