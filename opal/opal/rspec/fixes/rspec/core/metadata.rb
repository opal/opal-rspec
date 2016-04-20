module ::RSpec::Core::Metadata
  def self.relative_path(line)
    # Opal, caller.first will be passed in here but we have no caller, so handle nil
    return nil unless line
    # end Opal patch
    line = line.sub(relative_path_regex, "\\1.\\2".freeze)
    # opal, regex fix since \A is not supported
    line = line.sub(/^([^:]+:\d+)$/, '\\1'.freeze)
    #line = line.sub(/\A([^:]+:\d+)$/, '\\1'.freeze)
    return nil if line == '-e:1'.freeze
    line
  rescue SecurityError
    # :nocov:
    nil
    # :nocov:
  end

  class HashPopulator
    def populate_location_attributes
      backtrace = user_metadata.delete(:caller)
      # Throwing exceptions to get code location is expensive, so use this if the user supplied it, otherwise
      # keep empty stuff around so filter code does not crash

      # might have an empty array from caller which file_path_and_line_number_from doesn't like
      file_path, line_number = if backtrace && !backtrace.empty?
                                 file_path_and_line_number_from(backtrace)
                               else
                                 ['', -1]
                               end

      metadata[:file_path] = file_path
      metadata[:line_number] = line_number.to_i
      metadata[:location] = file_path.empty? ? '' : "#{file_path}:#{line_number}"
      metadata[:absolute_file_path] = file_path
      metadata[:rerun_file_path] ||= file_path
      metadata[:scoped_id] = ''
    end


    # Opal fix
    def build_description_from(parent_description=nil, my_description=nil)
      return parent_description.to_s unless my_description
      separator = description_separator(parent_description, my_description)
      # Opal, mutable strings
      # (parent_description.to_s + separator) << my_description.to_s
      (parent_description.to_s + separator) + my_description.to_s
    end
  end
end
