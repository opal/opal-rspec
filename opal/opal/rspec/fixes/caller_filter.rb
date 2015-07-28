# This breaks on 2.0.0, so it is here ready for when opal bumps to 2.0.0
class RSpec::CallerFilter
  def self.first_non_rspec_line
    ""
  end
end
