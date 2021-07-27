class RSpec::Core::Formatters::ExceptionPresenter
  def indent_lines(lines, failure_number)
    alignment_basis = ' ' * @indentation
    #               vv- WAS <<
    alignment_basis +=  "#{failure_number}) " if failure_number
    indentation = ' ' * alignment_basis.length

    lines.each_with_index.map do |line, index|
      if index == 0
        "#{alignment_basis}#{line}"
      elsif line.empty?
        line
      else
        "#{indentation}#{line}"
      end
    end
  end

  def fully_formatted(failure_number, colorizer=::RSpec::Core::Formatters::ConsoleCodes)
    lines = fully_formatted_lines(failure_number, colorizer)
    #                v- WAS <<
    lines.join("\n") + "\n"
  end


  def find_failed_line
    line_regex = RSpec.configuration.in_project_source_dir_regex
    loaded_spec_files = RSpec.configuration.loaded_spec_files

    out = exception_backtrace.find do |line|
      #                              vvvvvvvvvvvv- ADDED
      next unless (line_path = line[/(?:  from )?(.+?):(\d+)(|:\d+)/, 1])
      path = File.expand_path(line_path)
      loaded_spec_files.include?(path) || path =~ line_regex
      #                        vvvvvvvvvvvvvvvvvvv- ADDED
    end || exception_backtrace.grep(/ from [^<]/).first

    # ADDED:
    out&.sub('  from ', '')
  end
end