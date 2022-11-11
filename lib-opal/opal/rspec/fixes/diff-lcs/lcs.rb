require 'diff/lcs'

class << Diff::LCS
  # mutable strings
  def patch(src, patchset, direction = nil)
    # Normalize the patchset.
    has_changes, patchset = Diff::LCS::Internals.analyze_patchset(patchset)

    return src.respond_to?(:dup) ? src.dup : src unless has_changes

    string = src.is_a?(String)
    # Start with a new empty type of the source's class
    res = src.class.new

    res = [] if string

    direction ||= Diff::LCS::Internals.intuit_diff_direction(src, patchset)

    ai = bj = 0

    patch_map = PATCH_MAP[direction]

    patchset.each do |change|
      # Both Change and ContextChange support #action
      action = patch_map[change.action]

      case change
      when Diff::LCS::ContextChange
        case direction
        when :patch
          el = change.new_element
          op = change.old_position
          np = change.new_position
        when :unpatch
          el = change.old_element
          op = change.new_position
          np = change.old_position
        end

        case action
        when "-" # Remove details from the old string
          while ai < op
            res << (string ? src[ai, 1] : src[ai])
            ai += 1
            bj += 1
          end
          ai += 1
        when "+"
          while bj < np
            res << (string ? src[ai, 1] : src[ai])
            ai += 1
            bj += 1
          end

          res << el
          bj += 1
        when "="
          # This only appears in sdiff output with the SDiff callback.
          # Therefore, we only need to worry about dealing with a single
          # element.
          res << el

          ai += 1
          bj += 1
        when "!"
          while ai < op
            res << (string ? src[ai, 1] : src[ai])
            ai += 1
            bj += 1
          end

          bj += 1
          ai += 1

          res << el
        end
      when Diff::LCS::Change
        case action
        when "-"
          while ai < change.position
            res << (string ? src[ai, 1] : src[ai])
            ai += 1
            bj += 1
          end
          ai += 1
        when "+"
          while bj < change.position
            res << (string ? src[ai, 1] : src[ai])
            ai += 1
            bj += 1
          end

          bj += 1

          res << change.element
        end
      end
    end

    while ai < src.size
      res << (string ? src[ai, 1] : src[ai])
      ai += 1
      bj += 1
    end

    if string
      res.join
    else
      res
    end
  end
end
