module Opal
  module RSpec
    def self.get_constants_for(object)
      result = []
      %x{
        for (var prop in #{object}) {
          if (#{object}.hasOwnProperty(prop) && #{!`prop`.start_with?('$')}) {
            #{result << `prop`}
          }
        }
      }
      result.reject { |c| c == 'constructor' }
    end
  end
end
