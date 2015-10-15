module ::RSpec::Core::Metadata
  # https://github.com/opal/opal/issues/1090, fixed in Opal 0.9
  unless ::Opal::RSpec::Compatibility.and_works_with_lhs_nil?
    class ExampleGroupHash
      def described_class
        candidate = metadata[:description_args].first
        return candidate unless NilClass === candidate || String === candidate
        parent_group = metadata[:parent_example_group]
        # https://github.com/opal/opal/issues/1090, fixed in Opal 0.9
        # parent_group && parent_group[:described_class]
        if parent_group
          parent_group[:described_class]
        else
          nil
        end
      end
    end
  end

  class HashPopulator
    def populate_location_attributes
      backtrace = user_metadata.delete(:caller)

      file_path, line_number = if backtrace
                                 file_path_and_line_number_from(backtrace)
                                 # Opal 0.9 has a stub for this but it does not return anything
                               # elsif block.respond_to?(:source_location)
                               #   block.source_location
                               else
                                 file_path_and_line_number_from(caller)
                               end

      file_path = Metadata.relative_path(file_path)
      metadata[:file_path] = file_path
      metadata[:line_number] = line_number.to_i
      metadata[:location] = "#{file_path}:#{line_number}"
    end
  end
end
