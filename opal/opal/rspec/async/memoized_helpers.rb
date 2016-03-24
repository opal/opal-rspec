module ::RSpec::Core::MemoizedHelpers
  class ThreadsafeMemoized
    def subject_resolved(subject)
      @memoized[:subject] = subject
    end
  end

  class NonThreadSafeMemoized
    def subject_resolved(subject)
      @memoized[:subject] = subject
    end
  end
end
