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

  # Can't get paths yet in Opal
  def self.relative_path(line)
    nil
  end
end
