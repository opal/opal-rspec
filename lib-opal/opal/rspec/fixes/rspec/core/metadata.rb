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
                                 ['', -1]
                               end

      metadata[:file_path]   = file_path
      metadata[:line_number] = line_number.to_i
      metadata[:location]    = file_path.empty? ? '' : "#{file_path}:#{line_number}"
    end
  end
end
