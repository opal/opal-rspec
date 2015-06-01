class RSpec::Core::Example
  # more mutable strings
  def assign_generated_description
    if metadata[:description].empty? && (description = RSpec::Matchers.generated_description)
      metadata[:description] = description
      metadata[:full_description] = metadata[:full_description] + description # mutable string fix
    end
  rescue Exception => e
    set_exception(e, "while assigning the example description")
  ensure
    RSpec::Matchers.clear_generated_description
  end
  
  # Fix unnecessary deprecation warnings
  # Hash.public_instance_methods - Object.public_instance_methods, which is a part of metadata.rb/HashImitatable (included by ExecutionResult), returns the initialize method, which gets marked as deprecated. The intent of the issue_deprecation method though is to shift people away from using this as a hash. Initialize obviously is not indicative of hash usage (any new object will trip this up, and that should not happen).
  class ExecutionResult
    # There is no real constructor to preserve in example.rb's ExecutionResult class, so can eliminate the issue_deprecation call this way
    def initialize; end
  end  
end
