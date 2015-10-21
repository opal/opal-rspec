# https://github.com/opal/opal/pull/1152
unless Opal::RSpec::Compatibility.set_has_superset?
  class Set
    def superset?(set)
      set.is_a?(Set) or raise ArgumentError, "value must be a set"
      return false if size < set.size
      set.all? { |o| include?(o) }
    end

    alias >= superset?

    def proper_superset?(set)
      set.is_a?(Set) or raise ArgumentError, "value must be a set"
      return false if size <= set.size
      set.all? { |o| include?(o) }
    end

    alias > proper_superset?

    def subset?(set)
      set.is_a?(Set) or raise ArgumentError, "value must be a set"
      return false if set.size < size
      all? { |o| set.include?(o) }
    end

    alias <= subset?

    def proper_subset?(set)
      set.is_a?(Set) or raise ArgumentError, "value must be a set"
      return false if set.size <= size
      all? { |o| set.include?(o) }
    end

    alias < proper_subset?
  end
end
