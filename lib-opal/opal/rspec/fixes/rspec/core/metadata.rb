module ::RSpec::Core::Metadata
  class HashPopulator
    def populate_location_attributes
      backtrace = user_metadata.delete(:caller)

      file_path, line_number = if backtrace
                                 file_path_and_line_number_from(backtrace)
                               elsif block.respond_to?(:source_location)
                                 block.source_location
                               else
                                 file_path_and_line_number_from(caller)
                               end

      file_path ||= ""

      relative_file_path            = ::RSpec::Core::Metadata.relative_path(file_path)
      absolute_file_path            = File.expand_path(relative_file_path)
      metadata[:file_path]          = relative_file_path
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
      # WAS:
      # (parent_description.to_s + separator) << my_description.to_s
      # NOW:
      (parent_description.to_s + separator) + my_description.to_s
    end
  end
end
