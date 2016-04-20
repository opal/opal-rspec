class RSpec::Support::ComparableVersion
  def segments
    @segments ||= string.scan(/[a-z]+|\d+/i).map do |segment|
      # Opal, incompatible Regex with \A and \z
      if segment =~ /^\d+$/ # if segment =~ /\A\d+\z/
        segment.to_i
      else
        segment
      end
    end
  end
end
