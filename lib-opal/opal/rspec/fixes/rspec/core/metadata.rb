module ::RSpec::Core::Metadata
  class HashPopulator
    def populate_location_attributes
      backtrace = user_metadata.delete(:caller)
      # Throwing exceptions to get code location is expensive, so use this if the user supplied it, otherwise
      # keep empty stuff around so filter code does not crash

      # might have an empty array from caller which file_path_and_line_number_from doesn't like
      file_path, line_number = if backtrace && !backtrace.empty?
                                 file_path_and_line_number_from(backtrace)
                               else
                                 # WAS:
                                 # file_path_and_line_number_from(caller)
                                 ['', -1]
                               end

      relative_file_path            = RSpec::Core::Metadata.relative_path(file_path)
      absolute_file_path            = File.expand_path(relative_file_path)
      metadata[:file_path]          = file_path
      metadata[:line_number]        = line_number.to_i
      metadata[:location]           = "#{relative_file_path}:#{line_number}"
      metadata[:absolute_file_path] = absolute_file_path
      metadata[:rerun_file_path]  ||= relative_file_path
      metadata[:scoped_id]          = build_scoped_id_for(absolute_file_path)
    end

    def build_description_from(parent_description=nil, my_description=nil)
      return parent_description.to_s unless my_description
      return my_description.to_s if parent_description.to_s == ''
      separator = description_separator(parent_description, my_description)
      # Mutable strings
      # (parent_description.to_s + separator) << my_description.to_s
      (parent_description.to_s + separator) + my_description.to_s
    end
  end
end
