module Opal::RSpec::MemoizedHelpers
  def subject_resolved(subject)
    @memoized[:subject] = subject
  end
end

module ::RSpec::Core::MemoizedHelpers
  class ThreadsafeMemoized
    include Opal::RSpec::MemoizedHelpers
  end

  class NonThreadSafeMemoized
    include Opal::RSpec::MemoizedHelpers
  end
end
