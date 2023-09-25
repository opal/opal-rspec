# backtick_javascript: true

require 'rspec/core/configuration'

module ::RSpec; module Core; class Configuration
  def files_or_directories_to_run=(*files)
    files = files.flatten

    # patch: rspec -> opal-rspec
    if (command == 'opal-rspec' || Runner.running_in_drb?) && default_path && files.empty?
      files << default_path
    end

    @files_or_directories_to_run = files
    @files_to_run = nil
  end

  def requires=(paths)
    # can't change requires @ this stage, this method calls RubyProject which will crash on Opal
  end

  def remove_ruby_ext(str)
    str.gsub(/(?:\.js)?\.(?:rb|opal|\{rb,opal\})\z/, '')
  end

  def glob_to_re_expand_alternatives(glob)
    # If there are no braces, just return the string as an array
    return [glob] unless glob =~ /(.*)\{([^\{\}]*?)\}(.*)/

    prefix, contents, suffix = $1, $2, $3

    alternatives = contents.split(',')

    expanded_patterns = alternatives.map do |alternative|
      "#{prefix}#{alternative}#{suffix}"
    end

    # Recursively expand for the rest of the pattern
    return expanded_patterns.flat_map { |pattern| glob_to_re_expand_alternatives(pattern) }
  end

  def glob_to_re(path, pattern)
    pattern = remove_ruby_ext(pattern)
    if pattern.start_with?(path)
      path = ""
    else
      path += "/" unless path.end_with?("/")
    end
    pattern = path + pattern
    patterns = glob_to_re_expand_alternatives(pattern)
    re = patterns.map { |i| Regexp.escape(i) }.join("|").then { |i| "(?:#{i})" }
    re = re.gsub('\/\*\*\/', '(?:/|/.*?/)')
           .gsub('\*', '[^/]*?')
           .gsub('\?', '[^/]')
    re = '(?:^|/)' + re + "$"
    # Strip multiple '/'s
    re = re.gsub(%r{(\\/|/)+}, '/')
    # Strip the `/./`
    re = re.gsub('/\./', '/')
    re = re.gsub('(?:^|/)\./', '(?:^|/)')
    Regexp.new(re)
  end

  # Only load from loaded files
  def get_matching_files(path, pattern)
    if pattern.is_a?(Array)
      return pattern.map { |pat| get_matching_files(path, pat) }.flatten.sort.uniq
    end
    `Object.keys(Opal.modules)`.grep(glob_to_re(path, pattern)).sort
  end

  # A crude logic to check if a path is a directory perhaps...
  # This ought to work in places where we don't have a filesystem.
  def is_directory?(path)
    return true if path.end_with? '/'
    # This is passed with ":" if we run something like:
    # opal-rspec spec-opal-passing/tautology_spec.rb:8
    return false if path =~ /\[[0-9:]+\]$|:[0-9]+$/
    # Ruby files are certainly not directories
    return false if ['.rb', '.opal'].any? { |i| path.end_with? i }
    # Otherwise, let's check for modules
    !`Object.keys(Opal.modules)`.any? { |i| i.end_with?("/"+remove_ruby_ext(path)) }
  end

  def get_files_to_run(paths)
    files = paths_to_check(paths).flat_map do |path|
      path = path.gsub(File::ALT_SEPARATOR, File::SEPARATOR) if File::ALT_SEPARATOR
      is_directory?(path) ? gather_directories(path) : extract_location(path)
    end.uniq

    return files unless only_failures?
    relative_files = files.map { |f| Metadata.relative_path(File.expand_path f) }
    intersection = (relative_files & spec_files_with_failures.to_a)
    intersection.empty? ? files : intersection
  end

  def opal_special_load(file)
    file = remove_ruby_ext(file)
    long_file = `Object.keys(Opal.modules)`.find { |i| i.end_with?(file) }
    `Opal.modules[file] = Opal.modules[long_file]` if long_file

    # Let's try a normalized load
    `Opal.load_normalized(file)`
  rescue LoadError
    # Otherwise, a regular require
    require file
  end

  alias load_file_handling_errors_before_opal load_file_handling_errors

  def load_file_handling_errors(method, file)
    load_file_handling_errors_before_opal(:opal_special_load, file)
  end
end; end; end

class ::RSpec::Core::ConfigurationOptions
  # Opal-RSpec should work without need of filesystem
  # access, therefore we can't support access to the
  # options file.
  def options_file_as_erb_string(path)
    # ERB.new(File.read(path), nil, '-').result(binding)
    # ERB.new(File.read(path), nil, '-')
    ''
  end

  # Pass command line options directly
  def command_line_options
    $rspec_opts || {}
  end
end

# Set the default path to spec-opal, to be overwritten
# later.
RSpec.configuration.default_path = "spec-opal"
